
CREATE procedure [dbo].[st_getTransfersForHonduras]
(
    @BeginDate datetime ,    
    @EndDate datetime,
    @IdGateway int = null
)
as
declare @idcountry int = 10
declare @Datepivot datetime ='2014-04-30 00:00:00'
declare @DatepivotFixTNW datetime ='2015-09-18 17:16:19.297'

if @BeginDate is not null    
    Select  @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  

if @EndDate is not null
    Select  @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1) 

select     
    IdTransfer,
    Claimcode,
    DateOfTransfer,
    a.IdGateway,    
    GatewayName,
    a.IdPayer,
    PayerName,
    amountindollars AmountInDollarsMaxi,
    exrate ExrateMaxi,
    amountinmn AmountInMnMaxi,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot  then 
            case when a.IdGateway=3 and DateOfTransfer>=@DatepivotFixTNW then    
                round(A.AmountInMN /A.referenceexrate,4)
            else
                dbo.[funGetConvertAmount](amountinmn,referenceexrate) 
            end        
        else amountindollars
    end
    AmountInDollarsGateway,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot then referenceexrate 
        else exrate 
    end
    ExrateGateway,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot then 
            case when a.IdGateway=3 and DateOfTransfer>=@DatepivotFixTNW then    
                A.AmountInMN
            else
                round(dbo.[funGetConvertAmount](amountinmn,referenceexrate) * referenceexrate,4) 
            end
        else amountinmn
    end
    AmountInMnGateway,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot  then 1
        else 0
    end
    ApplyRefExrate
from 
    transfer A with (nolock)
Join CountryCurrency B with (nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)
left join 
    CountryExrateConfig cex with (nolock) on B.idcountry=cex.idcountry /*and cex.IdGenericStatus=1*/ and cex.idgateway=a.idgateway
join payer p with (nolock) on a.idpayer=p.idpayer
join gateway g with (nolock) on a.idgateway=g.idgateway
where b.idcountry=@idcountry and a.idgateway=isnull(@IdGateway,a.idgateway)
and a.DateOfTransfer>= isnull(@BeginDate,a.DateOfTransfer) and a.DateOfTransfer <= isnull(@EndDate,a.DateOfTransfer)

union all

select     
    IdTransferClosed IdTransfer,
    Claimcode,
    DateOfTransfer,
    a.IdGateway,    
    GatewayName,
    a.IdPayer,
    PayerName,
    amountindollars AmountInDollarsMaxi,
    exrate ExrateMaxi,
    amountinmn AmountInMnMaxi,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot  then 
            case when a.IdGateway=3 and DateOfTransfer>=@DatepivotFixTNW then    
                round(A.AmountInMN /A.referenceexrate,4)
            else
                dbo.[funGetConvertAmount](amountinmn,referenceexrate) 
            end        
        else amountindollars
    end
    AmountInDollarsGateway,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot then referenceexrate 
        else exrate 
    end
    ExrateGateway,
     case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot then 
            case when a.IdGateway=3 and DateOfTransfer>=@DatepivotFixTNW then    
                A.AmountInMN
            else
                round(dbo.[funGetConvertAmount](amountinmn,referenceexrate) * referenceexrate,4) 
            end
        else amountinmn
    end
    AmountInMnGateway,
    case 
        when isnull(UseRefExrate,0)=1 and a.dateoftransfer>=@Datepivot  then 1
        else 0
    end
    ApplyRefExrate
from 
    transferclosed A with (nolock)
Join CountryCurrency B with (nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)
left join 
    CountryExrateConfig cex with (nolock) on B.idcountry=cex.idcountry /*and cex.IdGenericStatus=1*/ and cex.idgateway=a.idgateway
--join payer p on a.idpayer=p.idpayer
--join gateway g on a.idgateway=g.idgateway
where b.idcountry=@idcountry and a.idgateway=isnull(@IdGateway,a.idgateway)
and a.DateOfTransfer>= isnull(@BeginDate,a.DateOfTransfer) and a.DateOfTransfer <= isnull(@EndDate,a.DateOfTransfer)

order by dateoftransfer