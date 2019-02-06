USE AdBoIntegration

--Объявляем таблицы
DECLARE @AdInsureTablePriod table(
	[ExternalID] nvarchar(max),
	[Name] nvarchar(max), 
	[Code] nvarchar(max), 
	[ExternalSubjectTypeID] nvarchar(max),
	[ModifiedDate] datetime,
	[IsDeleted] nvarchar(max)
)

--Записи, которые есть в AdInsure и нет в AdBo
DECLARE @AdInsureNotInAdBo table(
	[ExternalID] nvarchar(max),
	[Name] nvarchar(max), 
	[Code] nvarchar(max), 
	[ExternalSubjectTypeID] nvarchar(max),
	[ModifiedDate] datetime,
	[IsDeleted] nvarchar(max)
)

--AdBo за период
DECLARE @AdBoTablePeriod table(
	   [ID] int
      ,[UID] nvarchar(max)
      ,[SubjectTypeID] nvarchar(max)
      ,[Code] nvarchar(max)
      ,[Name] nvarchar(max)
      ,[IsVip] nvarchar(max)
      ,[Description] nvarchar(max)
      ,[IsDeleted] nvarchar(max)
      ,[CreatedDate] nvarchar(max)
      ,[ModifiedDate] nvarchar(max)
      ,[AdInsureId] nvarchar(max)
      ,[LocalModifiedDate] nvarchar(max)
      ,[NameBin] nvarchar(max)
)

DECLARE @RecordsNotInAdBo table(
		[ExternalID] nvarchar(max),
		[Name] nvarchar(max), 
		[Code] nvarchar(max), 
		[ExternalSubjectTypeID] nvarchar(max),
		[ModifiedDate] datetime,
		[IsDeleted] nvarchar(max)
)
--
DECLARE @AdBoTableNotInAdInsure table(
[ID] int
      ,[UID] nvarchar(max)
      ,[SubjectTypeID] nvarchar(max)
      ,[Code] nvarchar(max)
      ,[Name] nvarchar(max)
      ,[IsVip] nvarchar(max)
      ,[Description] nvarchar(max)
      ,[IsDeleted] nvarchar(max)
      ,[CreatedDate] nvarchar(max)
      ,[ModifiedDate] nvarchar(max)
      ,[AdInsureId] nvarchar(max)
      ,[LocalModifiedDate] nvarchar(max)
      ,[NameBin] nvarchar(max)
)
DECLARE @RecordsNotInAdInsure table(
	   [ID] int
      ,[UID] nvarchar(max)
      ,[SubjectTypeID] nvarchar(max)
      ,[Code] nvarchar(max)
      ,[Name] nvarchar(max)
      ,[IsVip] nvarchar(max)
      ,[Description] nvarchar(max)
      ,[IsDeleted] nvarchar(max)
      ,[CreatedDate] nvarchar(max)
      ,[ModifiedDate] nvarchar(max)
      ,[AdInsureId] nvarchar(max)
      ,[LocalModifiedDate] nvarchar(max)
      ,[NameBin] nvarchar(max)
)

DECLARE @queryVerifyTableAdInsure table (
	[ExternalID] nvarchar(max),
	[Name] nvarchar(max), 
	[Code] nvarchar(max), 
	[ExternalSubjectTypeID] nvarchar(max),
	[ModifiedDate] datetime,
	[IsDeleted] nvarchar(max)
)
--Объявляем переменные
DECLARE 
	@p_Date DateTime,
	@p_DateStop DateTime, 	
	@query nvarchar(max),
	@queryVerify nvarchar(max),
	@countQueryVerifyTableAdInsure int,
	@countAdBoTablePeriod int,
	@countAdInsureTablePeriod int,
	@countAdBoNotInAdInsure int,
	@countAdInsureNotInAdBo int,	
	@countQueryVerifyTableAdBo int,
	@AdInsureID nvarchar(max)

--Приcваиваем период
SET @p_Date = '2018-11-03 21:24:43.100' 
SET @p_DateStop = '2018-11-03 21:24:44.100'
SET @AdInsureID = ''
--Запрос к AdInsure данные по Subject за указанный период
--query не я писал, использую в своем запросе для выборки из оракловской БД
SET @query = CAST(N'' AS nvarchar(max)) +
					N'SELECT 
                    /*+ ordered
                        index(p)
                    */             
                    p.PERSON_ID "ExternalID",
					p.FULL_NAME "Name",
					p.ALTERNATIVE_CODE "Code",
                    p.PERSON_TYPE_ID "ExternalSubjectTypeID",
                    p.LAST_UPDATED "ModifiedDate",
                    p.ARCHIVED "IsDeleted"					
               FROM 
                    adinsure_vsk.RO_PERSON p
	  WHERE p.LAST_UPDATED >= to_timestamp('''+convert(nvarchar(30),@p_Date,121)+''',''yyyy-MM-DD hh24:mi:ss,ff3'')
         and p.LAST_UPDATED < to_timestamp('''+convert(nvarchar(30),@p_DateStop,121)+''',''yyyy-MM-DD hh24:mi:ss,ff3'')'

BEGIN
--Записи адакты за период

	INSERT INTO @AdInsureTablePriod EXEC(@query) at [ADINSURE_PROD_WRITE]

--Записи AdBo за период

	INSERT INTO @AdBoTablePeriod 
	SELECT * FROM  [AdBoIntegration].[dbo].[Subject]	
	WHERE
	ModifiedDate >= @p_Date 
	 and ModifiedDate < @p_DateStop
	 
	 END
	 --Общее количество записей AdBo за период
	 SET @countAdBoTablePeriod = (SELECT COUNT (*) FROM @AdBoTablePeriod)
	 --Общее количество записей AdInsure за период
	 SET @countAdInsureTablePeriod = (SELECT COUNT (*) FROM @AdInsureTablePriod)
	 --Количество записей в AdBo за период, которые не найдены в AdInsure
	 SET @countAdBoNotInAdInsure = (
			 SELECT 
				COUNT(*)
				FROM @AdInsureTablePriod adintp
				FULL OUTER JOIN @AdBoTablePeriod adbotp on adintp.ExternalID = adbotp.AdInsureId
			WHERE adintp.ExternalID IS NULL		
		)

	 --Количество записей в AdInsure за период, которые не найдены в AdBo
	 SET @countAdInsureNotInAdBo = (
			SELECT 
				COUNT(*)
				FROM @AdInsureTablePriod adintp
				FULL OUTER JOIN @AdBoTablePeriod adbotp on adintp.ExternalID = adbotp.AdInsureId
			WHERE adbotp.ID IS NULL
	 )
--Проверки за период
	BEGIN
		--Вывод записей за указанный период которые, есть в AdInsure и нет в AdBo
		IF @countAdInsureNotInAdBo > 0
			BEGIN
				INSERT INTO @AdInsureNotInAdBo
				SELECT 					
					adintp.* FROM @AdInsureTablePriod adintp
					FULL OUTER JOIN @AdBoTablePeriod adbotp on adintp.ExternalID = adbotp.AdInsureId
					WHERE adbotp.ID IS NULL

				--Смотрим вхождения AdInsure в AdBo по ID
				INSERT INTO @RecordsNotInAdBo
				SELECT 				
				adini.*
				 FROM @AdInsureTablePriod AS adini 
				FULL OUTER JOIN (
				SELECT
				*
				FROM (SELECT * FROM [Subject]) AS s WHERE s.AdInsureId IN (SELECT ExternalID FROM @AdInsureTablePriod)) AS adtp on adini.ExternalID = adtp.AdInsureId
				WHERE adtp.AdInsureId IS NULL
				
				SELECT 
				'Записи AdBo, которые не входят в перод выборки, но выбрались в AdInsure' AS [Result],
				*
				 FROM (SELECT * FROM [Subject]) AS s WHERE s.AdInsureID IN (SELECT ExternalID FROM @AdInsureNotInAdBo)
				
				--Записи которых нет в AdBo
				IF (SELECT COUNT(*) FROM @RecordsNotInAdBo) > 0
					BEGIN
						SELECT
						'Записи, которых нет в AdBo' AS [Result], 				
						adini.*
							FROM @AdInsureTablePriod AS adini 
						FULL OUTER JOIN (
						SELECT
						*
						FROM (SELECT * FROM [Subject]) AS s WHERE s.AdInsureId IN (SELECT ExternalID FROM @AdInsureTablePriod)) AS adtp on adini.ExternalID = adtp.AdInsureId
						WHERE adtp.AdInsureId IS NULL
					END
					ELSE
								BEGIN
									SELECT 'В AdBo по ID найдены все записи, которые имеются в AdInsure за указанный период' AS Result
								END			
			END
		----Вывод записей за указанный период которые, есть в AdBo и нет в AdInsure
		IF @countAdBoNotInAdInsure > 0
			BEGIN
				INSERT INTO @AdBoTableNotInAdInsure
				SELECT 					
					adbotp.* FROM @AdInsureTablePriod adintp
					FULL OUTER JOIN @AdBoTablePeriod adbotp on adintp.ExternalID = adbotp.AdInsureId
					WHERE adintp.ExternalID IS NULL
					--Создаем список AdInsureID
				 SELECT @AdInsureID = @AdInsureID +','+convert(nvarchar(max),AdInsureId) FROM @AdBoTableNotInAdInsure
				 --Удаляем первую запятую
				 SET @AdInsureID = (SELECT SUBSTRING(@AdInsureID, 2, LEN(@AdInsureID)))
				--Запрос к AdInsure данные по не найденным записям в запросе за указанный период. Поиск по AdInsureId
				IF @AdInsureID != ''
				
					BEGIN
					 SET @queryVerify = CAST(N'' AS nvarchar(max)) +
												N'SELECT 
													/*+ ordered
														index(p)
													*/             
													p.PERSON_ID "ExternalID",
													p.FULL_NAME "Name",
													p.ALTERNATIVE_CODE "Code",
													p.PERSON_TYPE_ID "ExternalSubjectTypeID",
													p.LAST_UPDATED "ModifiedDate",
													p.ARCHIVED "IsDeleted"					
												FROM 
													adinsure_vsk.RO_PERSON p
													WHERE p.PERSON_ID in ('+@AdInsureID+')'

					 INSERT INTO @queryVerifyTableAdInsure EXEC(@queryVerify) at [ADINSURE_PROD_WRITE]

					 --Вывод 'Записи AdInsure, у которых ModifideDate отличается от того что в AdBo'
					 SELECT
					 'Записи AdInsure, которые не входят в перод выборки, но выбрались в AdBo' AS [Result],
					 *
					 FROM @queryVerifyTableAdInsure

					 IF (SELECT COUNT(*) FROM @queryVerifyTableAdInsure) > 0
						BEGIN
						INSERT INTO @RecordsNotInAdInsure
							SELECT 							
							adtn.*
							FROM @queryVerifyTableAdInsure qvf
							FULL OUTER JOIN @AdBoTableNotInAdInsure adtn on qvf.ExternalID = adtn.AdInsureId
							WHERE qvf.ExternalID IS NULL

							IF (SELECT COUNT(*) FROM @RecordsNotInAdInsure) > 0
								BEGIN
									SELECT 
									'Записи, которых нет в AdInsure' AS [Result],
									adtn.*
									FROM @queryVerifyTableAdInsure qvf
									FULL OUTER JOIN @AdBoTableNotInAdInsure adtn on qvf.ExternalID = adtn.AdInsureId
									WHERE qvf.ExternalID IS NULL
								END
								ELSE
								BEGIN
									SELECT 'В AdInsure по ID найдены все записи, которые имеются в AdBo' AS Result
								END
						END
					 					 		
			END
	
	END

			IF @countAdBoTablePeriod = 0 and @countAdInsureTablePeriod = 0
				BEGIN
					SELECT 'Не найдено ни одной записи в AdInsure и AdBoIntegration за указанный период' AS Result
				END
			ELSE
				BEGIN
					IF @countAdBoNotInAdInsure = 0 and @countAdInsureNotInAdBo = 0
						BEGIN
							SELECT 'Проверка пройдена успешно' AS Result
						END
				END


END

GO