declare @katalog1 nvarchar(150)
declare @produkt1 nvarchar(150)
declare kur SCROLL cursor for 
SELECT dbo.Table_ean_produkt_powiazania_kluczy.kod_PF_z_farb FROM Table_ean_produkt_powiazania_kluczy
OPEN kur;
FETCH NEXT FROM kur INTO @produkt1;
WHILE @@FETCH_STATUS=0
    BEGIN
    	SELECT @katalog1 = dbo.Table_katalog.KATALOG FROM dbo.Table_katalog CROSS JOIN
                      dbo.Table_kolory CROSS JOIN
                      dbo.Table_rozmiar
		WHERE (dbo.Table_katalog.KATALOG + dbo.Table_rozmiar.ROZMIAR + ' ' + dbo.Table_kolory.kolor = @produkt1) 
		UPDATE  Table_ean_produkt_powiazania_kluczy SET dbo.Table_ean_produkt_powiazania_kluczy.katalog = @katalog1 WHERE kod_PF_z_farb = @produkt1       
     SET @katalog1='0';
    FETCH NEXT FROM kur INTO @produkt1;
    END
CLOSE kur  
DEALLOCATE kur
GO