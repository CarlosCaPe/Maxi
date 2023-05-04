CREATE procedure [Corp].[st_GetKYCRule]
(
    @All bit = null,
    @RuleName nvarchar(max) = null,
    @IdAgent int = null,
    @IdGateway int = null,
    @IdCountry int = null,
    @IdPaymentType int = null,
    @IdPayer int = null,
    @IdActor int = null
)
as
SET NOCOUNT ON;
declare @Actor nvarchar(max)

select @Actor=name from KYCActor with(nolock) where IdActor=@IdActor

select 
    IdRule,RuleName,k.EnterByIdUser,UserName,Creationdate,k.DateOfLastChange,k.IdGenericStatus, s.GenericStatus,k.ExpirationDate 
from 
    KYCRule k with(nolock)
join 
    users u with(nolock) on k.EnterByIdUser=u.IdUser
join
    GenericStatus s with(nolock) on k.IdGenericStatus=s.IdGenericStatus
where 
    k.IdGenericStatus= case when isnull(@All,0)=1 then k.IdGenericStatus else 1 end and
    RuleName like '%'+isnull(@RuleName,'')+'%' and
    isnull(k.IdAgent,0)=isnull(@IdAgent,isnull(k.IdAgent,0)) and
    isnull(k.IdGateway,0)=isnull(@IdGateway,isnull(k.IdGateway,0)) and
    isnull(k.IdCountry,0)=isnull(@IdCountry,isnull(k.IdCountry,0)) and
    isnull(k.IdPaymentType,0)=isnull(@IdPaymentType,isnull(k.IdPaymentType,0)) and
    isnull(k.IdPayer,0)=isnull(@IdPayer,isnull(k.IdPayer,0)) and
    isnull(k.Actor,'')=isnull(@Actor,isnull(k.Actor,''))
order by RuleName

