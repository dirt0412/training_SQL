USE [PRODUKCJA_1]
GO
/****** Object:  StoredProcedure [dbo].[Table_zlecenia_prod_zestawienie_PROCEDURE]    Script Date: 2014-03-31 02:36:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Table_zlecenia_prod_zestawienie_PROCEDURE] 
AS
BEGIN
SET NOCOUNT ON;
DELETE FROM PRODUKCJA_1.dbo.Table_zlecenia_prod_zestawienie;
INSERT INTO dbo.Table_zlecenia_prod_zestawienie 
(nr_zlecenia, Katalog, Rozmiar, IloscZlecona, IloscWykon, Palce, Karuzele, Klinowki, Rozcinanie, Autolapy, Przeznaczenie) 

SELECT dbo.Table_zlecenia_prod.nr_zlecenia, 
dbo.Table_glowna.KATALOG, 
dbo.Table_glowna.ROZMIAR, 
dbo.Table_zlecenia_prod.ilosc_zlecona AS IloscZlecona, 
dbo.Table_zlecenia_prod.ilosc_wykonana AS IloscWykon, 
SUM(CASE WHEN dbo.Table_glowna_s.NazwaMaszyny = 'PALCE' THEN dbo.Table_glowna_s.ILOSC ELSE 0 END) AS Palce, 
SUM(CASE WHEN dbo.Table_glowna_s.NazwaMaszyny = 'KARUZELE' THEN dbo.Table_glowna_s.ILOSC ELSE 0 END) AS Karuzele,  
SUM(CASE WHEN dbo.Table_glowna_s.NazwaMaszyny = 'KLINÓWKI' THEN dbo.Table_glowna_s.ILOSC ELSE 0 END) AS Klinowki, 
SUM(CASE WHEN dbo.Table_glowna_s.NazwaMaszyny = 'ROZCINANIE' THEN dbo.Table_glowna_s.ILOSC ELSE 0 END) AS Rozcinanie, 
SUM(CASE WHEN dbo.Table_glowna_s.NazwaMaszyny = 'AUTOLAPY' THEN dbo.Table_glowna_s.ILOSC ELSE 0 END) AS Autolapy, 
dbo.Table_przeznaczenie.przeznaczenie AS Przeznaczenie 
FROM dbo.Table_przeznaczenie 
RIGHT OUTER JOIN dbo.Table_zlecenia_prod ON dbo.Table_przeznaczenie.id_przeznaczenie = dbo.Table_zlecenia_prod.id_przeznaczenie 
RIGHT OUTER JOIN     dbo.Table_glowna 
LEFT OUTER JOIN  dbo.Table_glowna_s ON dbo.Table_glowna.EAN13 = dbo.Table_glowna_s.EAN13 ON dbo.Table_zlecenia_prod.ean13_zlecenia = dbo.Table_glowna.ean13_zlecenia 
WHERE  (dbo.Table_zlecenia_prod.ilosc_zlecona = dbo.Table_zlecenia_prod.ilosc_wykonana) OR (dbo.Table_zlecenia_prod.ilosc_zlecona < dbo.Table_zlecenia_prod.ilosc_wykonana) OR (dbo.Table_zlecenia_prod.ilosc_zlecona > dbo.Table_zlecenia_prod.ilosc_wykonana) 
GROUP BY dbo.Table_glowna.KATALOG, dbo.Table_glowna.ROZMIAR, dbo.Table_zlecenia_prod.ilosc_zlecona, dbo.Table_zlecenia_prod.ilosc_wykonana, dbo.Table_zlecenia_prod.nr_zlecenia, dbo.Table_przeznaczenie.przeznaczenie 
ORDER BY  dbo.Table_przeznaczenie.przeznaczenie, dbo.Table_glowna.KATALOG;

END