CREATE Procedure [dbo].[st_TransferCheckByBranch]    
(    
@IdAgentSchema INT,    
@IdBranch INT,    
@IdPaymentType INT,
@AmountInDollar MONEY,    
@Fee MONEY OUT,
@Total MONEY OUT,
@ExRate MONEY OUT,
@TotalinForeingCurrency MONEY OUT
)    
AS    
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Select @Fee=H.Fee,
@Total=@AmountInDollar+H.Fee,
@ExRate= F.RefExRate+B.SpreadValue+C.SpreadValue ,
@TotalinForeingCurrency=(F.RefExRate+B.SpreadValue+C.SpreadValue)*(@AmountInDollar+H.Fee) 
From  AgentSchema A with(nolock)    
JOIN AgentSchemaDetail B with(nolock) on (A.IdAgentSchema=B.IdAgentSchema)     
JOIN PayerConfig C with(nolock) on (B.IdPayerConfig=C.IdPayerConfig)    
JOIN Payer D with(nolock) on (C.IdPayer=D.IdPayer)    
JOIN Branch E with(nolock) on (E.IdPayer=D.IdPayer)    
JOIN RefExRate F with(nolock) on (F.IdCountryCurrency=C.IdCountryCurrency)
JOIN Fee G with(nolock) on (G.IdFee=A.IdFee)
JOIN FeeDetail H with(nolock) ON (G.IdFee=H.IdFee)    
Where B.IdAgentSchema=@IdAgentSchema    
AND C.IdGenericStatus=1    
AND E.IdGenericStatus=1
AND E.IdBranch=@IdBranch    
AND C.IdPaymentType=@IdPaymentType  
AND @AmountInDollar>=H.FromAmount 
AND @AmountInDollar<=H.ToAmount
