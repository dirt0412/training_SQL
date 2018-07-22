SELECT  p.nazwisko_imie AS [nazwisko imie], 

        typ_zdarzenia AS[wejcie],
        datawejscia AS[data wejcia],	
		timewejscia AS[czas wejcia],
        dataTime AS[data czas wejscia],
		typ_zdarzenia1 AS[wyjcie],
        datawyjscia AS[data wyjcia],
		timewyjscia AS[czas wyjscia],
        NextDate AS[data czas wyjscia],		
        CONVERT(varchar(2), DATEDIFF(minute, dataTime, NextDate)/60) + ':' + CONVERT(varchar(2), DATEDIFF(minute, dataTime, NextDate) % 60) as [czas pracy - godz:min],
        CONVERT(varchar(2),DATEDIFF(minute, dataTime, NextDate)/60) as [czas pracy godz],
		CONVERT(varchar(2),DATEDIFF(minute, dataTime, NextDate)%60) as [czas pracy min],
		kd.nazwa_dzialu AS[nazwa dzia-u],
        ke.nazwa_etatu AS[etat]
FROM(SELECT  id_pracownik,
                    data as datawejscia,
                    (SELECT  MIN(data)
                        FROM    Table_kadry_import T2
                        WHERE   T2.id_pracownik = T1.id_pracownik
                        AND     T2.dataTime > T1.dataTime

                        AND T2.typ_zdarzenia > T1.typ_zdarzenia
                    ) AS datawyjscia,
                    typ_zdarzenia,

                    (SELECT  MIN(typ_zdarzenia)
                        FROM    Table_kadry_import T2
                        WHERE   T2.id_pracownik = T1.id_pracownik
                        AND     T2.dataTime > T1.dataTime

                        AND T2.typ_zdarzenia > T1.typ_zdarzenia
                    ) AS typ_zdarzenia1,
                     dataTime,
                    (SELECT  MIN(dataTime)
                        FROM    Table_kadry_import T2
                        WHERE   T2.id_pracownik = T1.id_pracownik
                        AND     T2.dataTime > T1.dataTime

                        AND T2.typ_zdarzenia > T1.typ_zdarzenia
                    ) AS NextDate,
                    time as timewejscia,
                    (SELECT  MIN(time)
                        FROM Table_kadry_import T2
                     WHERE   T2.id_pracownik = T1.id_pracownik
                        AND T2.dataTime > T1.dataTime

                        AND T2.typ_zdarzenia > T1.typ_zdarzenia
                    ) AS timewyjscia
            FROM Table_kadry_import T1
        ) AS T

        LEFT OUTER JOIN Table_kadry_pracownik p ON T.id_pracownik = p.id_pracownik

        LEFT OUTER JOIN Table_kadry_dzial kd ON p.dzial = kd.id_dzial

        LEFT OUTER JOIN Table_kadry_etat ke ON p.rodzaj_etatu = ke.id_etatu