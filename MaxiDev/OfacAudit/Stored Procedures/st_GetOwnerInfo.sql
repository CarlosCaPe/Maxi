CREATE PROCEDURE [OfacAudit].[st_GetOwnerInfo]
(
    @IdGeneric INT,
    @IsOwner BIT
)
AS

declare @idcounty int

IF (@IsOwner=1)
BEGIN
    SELECT 
		o.IdOwner,o.Name,o.LastName,o.SecondLastName,o.Address,o.Address,o.City,o.State,
		o.Zipcode,o.IdType,o.IdNumber,o.IdExpirationDate,o.BornDate,isnull(o.BornCountry,'') BornCountry, isnull(c.CountyName,'') CountyName--o
	FROM owner o (NOLOCK)
		LEFT JOIN County c (NOLOCK) ON o.IdCounty = c.IdCounty--o
	WHERE idowner=@IdGeneric

    select @idcounty=idcounty from owner WHERE idowner=@IdGeneric 
END
ELSE
BEGIN
    SELECT 
		a.IdAgent IdOwner,isnull(a.GuarantorName,'') Name,isnull(a.GuarantorLastName,'') LastName,isnull(a.GuarantorSecondLastName,'') SecondLastName,isnull(a.GuarantorAddress,'') Address,isnull(a.GuarantorAddress,'') Address,
		isnull(a.GuarantorCity,'') City,isnull(a.GuarantorState,'') State,isnull(a.GuarantorZipcode,'') Zipcode,isnull(a.GuarantorIdType,'') IdType,isnull(a.GuarantorIdNumber,'') IdNumber,a.GuarantorIdExpirationDate IdExpirationDate,
		a.GuarantorBornDate BornDate,isnull(a.GuarantorBornCountry,'') BornCountry , isnull(c.CountyName,'') CountyName--o
	FROM agent a (NOLOCK)
		LEFT JOIN County c (NOLOCK) ON a.IdCountyGuarantor = c.IdCounty--o
		 WHERE idagent=@IdGeneric

    select @idcounty=IdCountyGuarantor from agent WHERE idagent=@IdGeneric
END

select r.IdCountyClass, c.CountyClassName from RelationCountyCountyClass r 
join CountyClass c on r.IdCountyClass = c.IdCountyClass where idcounty=@idcounty
