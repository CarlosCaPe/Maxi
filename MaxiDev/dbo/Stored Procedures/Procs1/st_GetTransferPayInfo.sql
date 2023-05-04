CREATE PROCEDURE [dbo].[st_GetTransferPayInfo]                              
(
    @IdTransfer int
)
As
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select 
    t.IdTransfer,
    t.ClaimCode,    
    g.GatewayName,
    t.DateOfTransfer DateSend,
    isnull(t.GatewayBranchCode,'') BranchSend,    
    isnull(c.CityName,'') CitySend,
    isnull(s.StateName,'') StateSend,    
    tpi.DateOfPayment DatePayment,
    isnull(tpi.BranchCode,'') BranchReceive,
    --isnull(dbo.funPayInfoGetCity(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') CityReceive,
    --isnull(dbo.funPayInfoGetState(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') StateReceive,
    --isnull(dbo.funPayInfoGetAddress(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveAddress,    
    isnull(cr.cityname,'') CityReceive,
    isnull(sr.statename,'') StateReceive,
    isnull(br.[address],'') BranchReceiveAddress,
    isnull(tpi.BeneficiaryIdNumber,'') BeneficiaryIDNumber ,
    isnull(tpi.BeneficiaryIdType,'') BeneficiaryIDType
    from [Transfer] t with(nolock)
join Gateway g with(nolock)
    on g.IdGateway=t.IdGateway
left join Branch 
    b with(nolock) on b.IdBranch=t.IdBranch
left join 
    city c with(nolock) on b.IdCity=c.IdCity
left join 
    [state] s with(nolock) on c.IdState=s.IdState
left join 
    TransferPayInfo tpi with(nolock) on t.idtransfer=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo with(nolock) where IdTransfer =t.idtransfer)
left join 
    branch br with(nolock) on br.idbranch=tpi.idbranch   
left join 
    city cr with(nolock) on br.idcity=cr.idcity  
left join 
    [state] sr with(nolock) on cr.idstate=sr.idstate  
where 
    t.idtransfer=@IdTransfer
union
select 
    t.idtransferclosed IdTransfer,
    t.ClaimCode,    
    g.GatewayName,
    t.DateOfTransfer DateSend,
    isnull(t.GatewayBranchCode,'') BranchSend,    
    isnull(c.CityName,'') CitySend,
    isnull(s.StateName,'') StateSend,    
    tpi.DateOfPayment DatePayment,
    isnull(tpi.BranchCode,'') BranchReceive,
    --isnull(dbo.funPayInfoGetCity(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') CityReceive,
    --isnull(dbo.funPayInfoGetState(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') StateReceive,
    --isnull(dbo.funPayInfoGetAddress(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveAddress,        
    isnull(cr.cityname,'') CityReceive,
    isnull(sr.statename,'') StateReceive,
    isnull(br.[address],'') BranchReceiveAddress,
    isnull(tpi.BeneficiaryIdNumber,'') BeneficiaryIDNumber ,
    isnull(tpi.BeneficiaryIdType,'') BeneficiaryIDType
    from Transferclosed t with(nolock)
join Gateway g with(nolock)
    on g.IdGateway=t.IdGateway
left join Branch 
    b with(nolock) on b.IdBranch=t.IdBranch
left join 
    city c with(nolock) on b.IdCity=c.IdCity
left join 
    [state] s with(nolock) on c.IdState=s.IdState
left join 
    TransferPayInfo tpi with(nolock) on t.idtransferclosed=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo with(nolock) where IdTransfer =t.idtransferclosed)
left join 
    branch br with(nolock) on br.idbranch=tpi.idbranch   
left join 
    city cr with(nolock) on cr.idcity=br.idcity  
left join 
    [state] sr with(nolock) on cr.idstate=sr.idstate  
where 
    t.idtransferclosed=@IdTransfer
  
/*
select 
    top 1
    tp.idtransfer,    
    tp.ClaimCode,
    g.GatewayName,
    t.DateOfTransfer DateSend,
    isnull(t.gatewaybranchcode,'') BranchSend,

    tp.DateOfPayment,    
    tp.BranchCode BranchReceive,
    upper(isnull(c.CityName,@CityName)) CityReceive,
    upper(isnull(s.StateName,@StateName)) StateReceive,
    upper(isnull(b.Address,@Address)) BranchAddress,
    tp.BeneficiaryIdNumber,
    tp.BeneficiaryIdType
from 
    TransferPayInfo tp
join
(
    select idtransfer,idbranch,IdPayer,DateOfTransfer,gatewaybranchcode from transfer
    union 
    select idtransferclosed idtransfer,idbranch,IdPayer,DateOfTransfer,gatewaybranchcode from transferclosed
) t on tp.idtransfer=t.idtransfer
left join
    GatewayBranch gb on 
        gb.GatewayBranchCode=
            case (tp.IdGateway)
            when 9 then 
                case (IdPayer)
                    when 725 then tp.BranchCode --facach
                    else 
                        case (substring(tp.BranchCode,4,len(tp.BranchCode)-3))
                        when '01' then '1'
                        when '02' then '2'
                        when '03' then '3'
                        when '04' then '4'
                        when '05' then '5'
                        when '06' then '6'
                        when '07' then '7'
                        when '08' then '8'
                        when '09' then '9'
                        else
                            substring(tp.BranchCode,4,len(tp.BranchCode)-3)
                        end
                end                                
            else
                tp.BranchCode 
            end
        and 
        tp.IdGateway=gb.IdGateway 
        and 
        gb.IdBranch=t.IdBranch
left join 
    branch b on gb.IdBranch=b.IdBranch 
left join 
    gateway g on tp.IdGateway=g.IdGateway    
left join 
    city c on b.IdCity=c.IdCity
left join 
    state s on c.IdState=s.IdState
where tp.IdTransfer=@IdTransfer
order by tp.DateOfPayment desc
*/
