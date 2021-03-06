USE AdBoIntegration

--Объявляем таблицы
--Таблица AdInsure
DECLARE @AdInsureTablePeriod table(
        ExternalBillItemID nvarchar(max)
       ,ExternalBillID  nvarchar(max)
	   ,ExternalCurrencyID nvarchar(max)
	   ,ExternalInsuranceContractID nvarchar(max)
	   ,ExternalBillItemStatusID nvarchar(max)
       ,Amount nvarchar(max)       
       ,CommissionAmount nvarchar(max)
       ,CommissionPercent nvarchar(max)
       ,DocumentNumber nvarchar(max)
	   ,ErrorDescription nvarchar(max)
	   ,InputType nvarchar(max)
       ,ModifiedDate datetime       
)

--Таблица AdBoIntegration
DECLARE @AdBoTable table (
        [ID] int 
      ,[UID] nvarchar(max)
      ,[BillID] nvarchar(max)
      ,[Amount] nvarchar(max)
      ,[CurrencyID] nvarchar(max)
      ,[CommissionAmount] nvarchar(max)
      ,[CommissionPercent] nvarchar(max)
      ,[DocumentNumber] nvarchar(max)
      ,[ErrorDescription] nvarchar(max)
      ,[InputType] nvarchar(max)
      ,[CreatedDate] datetime
      ,[ModifiedDate] datetime
      ,[AdInsureID] nvarchar(max)
      ,[InsuranceContractID] nvarchar(max)
      ,[LocalModifiedDate] datetime
      ,[StatusID] nvarchar(max)
)

--Объявляем переменные
DECLARE 
       @p_Date DateTime,
       @p_DateStop DateTime,      
       @query nvarchar(max),
       @countAdInsureTable int,
       @countAdBoTable int,       
       @AdInsureID nvarchar(max),
	   @ModifiedDate datetime

--Приcваиваем период
SET @ModifiedDate = (SELECT top 1 ModifiedDate
  FROM [AdBoIntegration].[dbo].[BillItem]
  order by ModifiedDate desc)

SET @p_Date = DATEADD(DD,-7,@ModifiedDate)
SET @p_DateStop = @ModifiedDate
SET @AdInsureID = ''
--query не я писал, использую в своем запросе для выборки из оракловской БД
set @query = CAST(N'' AS nvarchar(max)) +      
             N'
		  SELECT
			  it.group_payment_item_id "ExternalBillItemID",
			  it.group_payment_id "ExternalBillID", 
			  it.currency_id "ExternalCurrencyID",
			  p.policy_id "ExternalInsuranceContractID",
			  it.status "ExternalBillItemStatusID", 
			  it.amount "Amount", 
			  it.commission_amount "CommissionAmount", 
			  it.commission_percentage "CommissionPercent", 
			  it.document "DocumentNumber", 
			  it.error_description "ErrorDescription",
			  it.input_type_id "InputType", 
			  (case when (case when it.last_updated > p.last_updated then it.last_updated else p.last_updated end)>t.last_updated then
					 (case when it.last_updated > p.last_updated then it.last_updated else p.last_updated end)
				  else t.last_updated
				  end) "ModifiedDate"
		  FROM adinsure_vsk.cf_group_payment_item it
			  join adinsure_vsk.cf_group_payment t on t.group_payment_id = it.group_payment_id          
			  join ADINSURE_VSK.IMP_BD_BILLING_DOCUMENT_ITEM re
				   join adinsure_vsk.rp_policy p
						on (re.policy_no = p.policy_no or re.policy_no = p.alt_policy_no) 
						   and POLICY_STATUS_ID in (4,5,6,7,8,9)
						   and POLICY_TYPE_ID in (1,2,5)        
				 on it.group_payment_item_id = re.billing_document_item_id
		  WHERE 
			  (case when (case when it.last_updated > p.last_updated then it.last_updated else p.last_updated end)>t.last_updated then
					 (case when it.last_updated > p.last_updated then it.last_updated else p.last_updated end)
				  else t.last_updated
				  end) >= to_timestamp('''+convert(nvarchar(30),@p_Date,121)+''',''yyyy-MM-DD hh24:mi:ss,ff3'')
			  and (case when (case when it.last_updated > p.last_updated then it.last_updated else p.last_updated end)>t.last_updated then
						 (case when it.last_updated > p.last_updated then it.last_updated else p.last_updated end)
					  else t.last_updated
					  end) < to_timestamp('''+convert(nvarchar(30),@p_DateStop,121)+''',''yyyy-MM-DD hh24:mi:ss,ff3'')
			  and t.status <> ''P'' 
		'


	   --Записи адакты за период       
	   insert into @AdInsureTablePeriod EXEC(@query) at [ADINSURE_PROD_WRITE]
       
             
       set @countAdInsureTable = (select count(*) from @AdInsureTablePeriod)
       --Записи адакты по ID из AdInsure
       insert into @AdBoTable 
             select 
             *            
             from [BillItem]
             where AdInsureId in (select ExternalBillItemID+'•'+ExternalInsuranceContractID from @AdInsureTablePeriod)  
       
       set @countAdBoTable = (select count(*) from @AdBoTable)
BEGIN  

       IF @countAdInsureTable > @countAdBoTable
             BEGIN
                    select 
                    'Записи, которые отсутсвуют в AdBoIntegration' as [Message]
                    ,atp.* 
                    from @AdInsureTablePeriod atp
                    left join @AdBoTable abt
                           on abt.AdInsureId = atp.ExternalBillItemID+'•'+atp.ExternalInsuranceContractID
                    where abt.AdInsureId is null
             END
       ELSE select 'Проверка пройдена успешно' as [Message] 

END
