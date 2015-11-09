DECLARE @ID INT

declare kursor SCROLL cursor for 
SELECT id_opakowania FROM  Table_opakowania ORDER BY id_opakowania
OPEN kursor;
FETCH NEXT FROM kursor INTO @ID;
WHILE @@FETCH_STATUS=0
    BEGIN
    --PRINT @ID;

UPDATE  Table_opakowania SET stan_pakownia_opak 
 =
ISNULL((SELECT  SUM(ilosc_remanent) as ilosc
FROM  Table_remanent_opak 
WHERE zatwierdzony='True' AND data_remanentu='2015-03-20' 
AND id_opak=@ID 
GROUP BY data_remanentu, id_opak,zatwierdzony),0)
+
ISNULL((SELECT  SUM(ilosc) AS ilosc
 FROM  Table_opakowania_operacje 
 WHERE data >= '2015-03-20' AND data <='2015-11-09' 
 AND zatwierdzony='True' 
 AND id_opak=@ID 
 GROUP BY id_opak, zatwierdzony),0)
 WHERE  id_opakowania=@ID;

 FETCH NEXT FROM kursor INTO @ID;
    END
CLOSE kursor   
DEALLOCATE kursor