SELECT TOP 1000 
p.PaymentTypeID,
p.ID,
p.InsuranceCurrencySum,
p.PaymentCurrencySum,
bip.PaymentMatchingDate,
iopf.InsuranceContractID,
iopf.InsuranceContractNumber,
iopf.ConclusionDate,
iopf.CommissionPercent,
iopf.DataSourceID,
iop.[Description],
d.Code [Код подразделения],
sa.ID [ИД Агента],
sa.Code [Код агента],
sa.Name [Имя агента],
ss.Code [ЮЛ КП код],
ss.Name [ЮЛ КП имя],
si.ID [Ид страхователя],
si.code [Код страхователя],
si.Name [Имя страхователя],
c.ShortName [Вид страхования],
sc.Code,
sc.Name [Канал продаж],
iopf.ModifiedDate,
bip.IsFake [Квитовка],
--case bip.IsFake
--when 1 then 'Прямая квитовка'
--else 0 then 'Обычная квитовка'
--else null then 'Квитовок нет') [Квитовка],
iop.ID,
cp.KV
--iopc.CommissionPercent [КВ ДС]

FROM [AdBoIntegration].[dbo].[InsuranceContractOptionFinal] iopf WITH (NOLOCK)
LEFT JOIN [AdBoIntegration].[dbo].[Subject] sa WITH (NOLOCK) ON iopf.AgentID = sa.ID
LEFT JOIN [AdBoIntegration].[dbo].[Subject] si WITH (NOLOCK) ON iopf.InsurantID = si.ID
LEFT JOIN [AdBoIntegration].[dbo].[Subject] ss WITH (NOLOCK) ON iopf.LegalPersonForSlChID = ss.ID
LEFT JOIN [AdBoIntegration].[dbo].[Condition] c WITH (NOLOCK) ON iopf.InsuranceTypeID = c.ID
INNER JOIN [AdBoIntegration].[dbo].[Division] d WITH (NOLOCK) ON iopf.DivisionID = d.ID
INNER JOIN [AdBoIntegration].[dbo].[SaleChannel] sc WITH (NOLOCK) ON iopf.SaleChannelID = sc.ID
INNER JOIN [AdBoIntegration].[dbo].[InsuranceObject] iob WITH (NOLOCK) ON iopf.InsuranceContractID = iob.InsuranceContractID
INNER JOIN [AdBoIntegration].[dbo].[InsuranceOption] iop WITH (NOLOCK) ON iopf.InsuranceContractID = iop.InsuranceContractID
INNER JOIN [AdBoIntegration].[dbo].[Payment] p WITH (NOLOCK) ON p.InsuranceOptionID = iop.ID
LEFT JOIN [AdBoIntegration].[dbo].[BillItemPayment] bip WITH (NOLOCK) ON p.ID = bip.PaymentID
LEFT JOIN [AdBoIntegration].[dbo].[CommissionPercent] cp WITH (NOLOCK) ON cp.InsuranceContractID = iopf.InsuranceContractID
--LEFT JOIN [AdBoIntegration].[dbo].[InsuranceOptionCommission] iopc WITH (NOLOCK) ON iop.ID = iopc.InsuranceOptionID

WHERE 
--iopf.ConclusionDate between '20180901' and '20180930' and 
--iopf.ConclusionDate between '20181201' and '20181231' and
--d.Code like '32%' and
--bip.PaymentMatchingDate between '20181201' and '20181231' and
--sc.Code = 362 and
----and bip.PaymentMatchingDate between '20180101' and '20181220' --фильтр по периоду для Бонус КАСКО
c.ShortName in ('@') --('$','&','2','3') - ЗК
--									 --('0','*','&','$') ДС
--									 --('0','*') Дижитал
--									 --('@') ОПО
--									 --Бонус ('К')
--and iopf.CommissionPercent = 0  --10 для ДС
--								--0 для дижитал
--and iopf.DataSourceID = 410
--Legacy
--and (iopf.DataSourceID = 487 or iop.[Description] like 'КАСКО ФЛ компакт%')
and p.PaymentTypeID in (
96,   --Взаимозачет возврата премии с поступлением страховой премии
113,	--Отмена отнесения поступившего платежа на договор страхования
117,	--Отнесение платежа на договор страхования
118,	--Отнесение поступившего платежа на договор страхования
122,	--Удержанное вознаграждение
127   --Отмена удержанного агентского вознаграждения
	) 
--and bip.IsFake = 1
--and si.code = ''
 and iopf.InsuranceContractNumber in (

)
 --and bip.IsFake is not null
--and sc.Name = 'Агенты ЦРС' -- [Канал продаж]
-- and sa.Code in (             -- [Агент]     
----указать нужного агента
--'')
