declare @dataBORemanent DATE;
declare @dataAktualna DATE;
declare @farbiarnia_stan INT;
declare @pakownia_stan INT;
declare @remanent_stan INT;
declare @zakupy INT;
SET @dataBORemanent = (SELECT TOP(1) data_remanent FROM dbo.Table_remanent_pakownia WHERE czy_zatw = 'True' ORDER BY data_remanent DESC);
SET @dataAktualna = GETDATE();
--select @dataAktualna;
DECLARE @KLUCZ NVARCHAR(50);
DELETE FROM Table_stan_mag1;

--tworzenie tabel tymczasowych
DELETE FROM Table_z_farb_do_pakow_temp; 
INSERT INTO Table_z_farb_do_pakow_temp  (id_dok_WZ, zatwierdzony, nr_dok, data, katalog, rozmiar, kolor, ilosc_wyslana, ilosc_dobra, braki, 
przefarb, waga, ilosc_przyjeta, id_farbiarnia, typ_dok, id_pracownik, farbowany, data_pilne, pakowany, nr_pakowania, 
wydruk_pak, ilosc_wyslana_WZ_przed_korekta, data_nadania_nr_WZ, data_powrotu, dok_korektaWZ, przefarb_braki_analiza, id_uwagi, delta, 
kod_ean_pakownia, zatwierdzony_pakownia, braki_pakownia, drugi_gatunek_pakownia, opakowanie, stan_mag, nr_dok1)  
SELECT  id_dok_WZ, zatwierdzony, nr_dok, data, katalog, rozmiar, kolor, ilosc_wyslana, ilosc_dobra, braki, przefarb, waga, ilosc_przyjeta, 
id_farbiarnia, typ_dok, id_pracownik, farbowany, data_pilne, pakowany, nr_pakowania, wydruk_pak, ilosc_wyslana_WZ_przed_korekta, 
data_nadania_nr_WZ, data_powrotu, dok_korektaWZ, przefarb_braki_analiza, id_uwagi, delta, kod_ean_pakownia, zatwierdzony_pakownia, 
braki_pakownia, drugi_gatunek_pakownia, opakowanie, stan_mag, nr_dok1 
FROM Table_z_farb_do_pakow WHERE (data_powrotu BETWEEN  @dataBORemanent AND @dataAktualna);
DELETE FROM  Table_magazyn_pakownia_user_temp; 
INSERT INTO  Table_magazyn_pakownia_user_temp  ( id_kierunek_wg, id_magazyn_wg, id_pracownik, data_zapisu, katalog, rozmiar, kolor, 
ilosc, zatwierdzony, wydruk, data_zatwierdzenia,                       nr_dok_wz, produkt, ean13_produkt, id_dostawca, wielokrotnosc, 
ean13_kosze, gora_dol)  SELECT  id_kierunek_wg, id_magazyn_wg, id_pracownik, data_zapisu, katalog, rozmiar, kolor, ilosc, zatwierdzony, 
wydruk, data_zatwierdzenia, nr_dok_wz, produkt, ean13_produkt, id_dostawca, wielokrotnosc, ean13_kosze, gora_dol 
FROM  Table_magazyn_pakownia_user WHERE (data_zapisu BETWEEN @dataBORemanent AND @dataAktualna);

declare kursor SCROLL cursor for 
----
SELECT DISTINCT produkt FROM dbo.Table_remanent_pakownia 
WHERE data_remanent BETWEEN @dataBORemanent AND @dataAktualna 
UNION SELECT DISTINCT katalog+rozmiar+' '+kolor AS klucz FROM dbo.Table_z_farb_do_pakow_temp 
WHERE data_powrotu BETWEEN @dataBORemanent AND @dataAktualna  
UNION SELECT DISTINCT katalog+rozmiar+' '+kolor AS klucz FROM dbo.Table_magazyn_pakownia_user_temp 
WHERE data_zapisu BETWEEN @dataBORemanent AND @dataAktualna;
----
OPEN kursor;
FETCH NEXT FROM kursor INTO @KLUCZ;
WHILE @@FETCH_STATUS=0
BEGIN

SET @farbiarnia_stan = ISNULL((SELECT SUM(ilosc_przyjeta) AS Ilosc FROM dbo.Table_z_farb_do_pakow_temp 
WHERE (data_powrotu BETWEEN @dataBORemanent AND @dataAktualna) AND (katalog + rozmiar + ' ' + kolor = @KLUCZ) AND id_dok_WZ <> 0 ),0);
--AND (id_dok_WZ <> 0 OR id_dok_WZ = 0)
SET @pakownia_stan = ISNULL((SELECT SUM(ilosc*wielokrotnosc) AS Ilosc FROM dbo.Table_magazyn_pakownia_user_temp 
WHERE (data_zapisu BETWEEN @dataBORemanent AND @dataAktualna) AND (katalog + rozmiar + ' ' + kolor = @KLUCZ) AND zatwierdzony='True'
    AND (id_kierunek_wg=2 OR id_kierunek_wg=3 OR id_kierunek_wg=7 OR id_kierunek_wg=6 OR id_kierunek_wg=4 OR id_kierunek_wg=9) ),0);
--AND (ean13_kosze = '-1' OR ean13_kosze <> '-1')
SET @remanent_stan = ISNULL((SELECT SUM(stan_remanent) AS stan_remanent FROM dbo.Table_remanent_pakownia 
WHERE (produkt = @KLUCZ) AND (data_remanent = @dataBORemanent) AND czy_zatw = 'True' 
AND czy_braki = 'False' AND czy_2gatunek = 'False'  AND czy_przefarb = 'False'),0);
SET @zakupy = ISNULL(( SELECT SUM(ilosc_przyjeta) AS Ilosc FROM dbo.Table_z_farb_do_pakow_temp 
 WHERE (data_powrotu BETWEEN @dataBORemanent AND @dataAktualna) AND (katalog + rozmiar + ' ' + kolor = @KLUCZ) AND id_dok_WZ = 0 ),0);

INSERT INTO Table_stan_mag1 VALUES(
--produkt - produkt
ISNULL((SELECT produkt FROM Table_ean_produkt WHERE ean13 = 
(SELECT TOP 1  ean13 FROM Table_ean_produkt_powiazania_kluczy WHERE kod_PF_z_farb = @KLUCZ)),0),
--ean13 - ean13
ISNULL((SELECT ean13 FROM Table_ean_produkt WHERE ean13 = 
(SELECT TOP 1  ean13 FROM Table_ean_produkt_powiazania_kluczy WHERE kod_PF_z_farb = @KLUCZ)),0),
--klucz - Klucz
@KLUCZ ,
--remanent - Remanent
@remanent_stan,
--farbiarnia - Z farbowania
@farbiarnia_stan,
--pakownia - Rozchody
@pakownia_stan,

--stan_mag - STAN MAGAZYNOWY
--remanent
@remanent_stan
+
--farbiarnia 
@farbiarnia_stan + @zakupy
-
--pakownia 
@pakownia_stan,
--stan_mag - KONIEC

--WZ_niezatwierdzone 
ISNULL((SELECT  SUM(dbo.Table_dok_mag_zewn.ilosc_dobra) AS Ilosc 
FROM  dbo.Table_dok_mag_zewn
 WHERE (dbo.Table_dok_mag_zewn.data_farbiarnia BETWEEN @dataBORemanent AND @dataAktualna)  
 AND dbo.Table_dok_mag_zewn.typ_dok = 'WZ' AND dbo.Table_dok_mag_zewn.zatwierdzony='False' 
 AND katalog + rozmiar + ' ' + kolor IN (SELECT @KLUCZ AS Expr1 UNION ALL SELECT klucz_filtr 
 FROM  Table_kody_dostawa_powiazanie WHERE (klucz_przydzielony = @KLUCZ)) 
 GROUP BY dbo.Table_dok_mag_zewn.katalog, dbo.Table_dok_mag_zewn.rozmiar, dbo.Table_dok_mag_zewn.kolor),0),
 --valueForSale - Zakupy
 @zakupy
 

)--end VALUES

FETCH NEXT FROM kursor INTO @KLUCZ;
END
CLOSE kursor   
DEALLOCATE kursor