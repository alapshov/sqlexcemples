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
d.Code [��� �������������],
sa.ID [�� ������],
sa.Code [��� ������],
sa.Name [��� ������],
ss.Code [�� �� ���],
ss.Name [�� �� ���],
si.ID [�� ������������],
si.code [��� ������������],
si.Name [��� ������������],
c.ShortName [��� �����������],
sc.Code,
sc.Name [����� ������],
iopf.ModifiedDate,
bip.IsFake [��������],
--case bip.IsFake
--when 1 then '������ ��������'
--else 0 then '������� ��������'
--else null then '�������� ���') [��������],
iop.ID,
cp.KV
--iopc.CommissionPercent [�� ��]

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
----and bip.PaymentMatchingDate between '20180101' and '20181220' --������ �� ������� ��� ����� �����
c.ShortName in ('@') --('$','&','2','3') - ��
--									 --('0','*','&','$') ��
--									 --('0','*') �������
--									 --('@') ���
--									 --����� ('�')
--and iopf.CommissionPercent = 0  --10 ��� ��
--								--0 ��� �������
--and iopf.DataSourceID = 410
--Legacy
--and (iopf.DataSourceID = 487 or iop.[Description] like '����� �� �������%')
and p.PaymentTypeID in (
96,   --����������� �������� ������ � ������������ ��������� ������
113,	--������ ��������� ������������ ������� �� ������� �����������
117,	--��������� ������� �� ������� �����������
118,	--��������� ������������ ������� �� ������� �����������
122,	--���������� ��������������
127   --������ ����������� ���������� ��������������
	) 
--and bip.IsFake = 1
--and si.code = ''
 and iopf.InsuranceContractNumber in (

)
 --and bip.IsFake is not null
--and sc.Name = '������ ���' -- [����� ������]
-- and sa.Code in (             -- [�����]     
----������� ������� ������
--'')
