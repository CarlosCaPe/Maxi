CREATE PROCEDURE [Corp].[st_GetChecksByHoldStatus]

@IdStatus int,
@Search Varchar (max),
@IdCheck int,
@startDate datetime,
@endDate datetime


as
--15 OFAC HOLD
If @IdStatus in (12,15,57,61,64) -- If IdStatus is Hold use the correspondent StatusName for that IdStatus and hard code it
Begin

if(@IdCheck = 0)
Begin
       Select top 1500 c.IdCheck, C.IdAgent,  A.AgentCode, C.Name, C.FirstLastName, C.SecondLastName, CU.PhysicalIdCopy  as CustomerPhysicalIdCopy,
                     A.AgentName, C.DateOfMovement, C.IdCheck, C.Amount, C.IdStatus, S.StatusName,
                     C.IdCustomer, [dbo].[fun_GetLastReview](C.IdCheck) as LastReview
                     ,Convert(bit,case when LC.IdUploadFile is not null or LT.IdUploadFile is not null then 1 else 0 end) HasFiles,                     
			          case when @Idstatus = 15 then
			          (select count(1) from [CheckHolds]  Tho with(nolock) where Tho.IdCheck = C.IdCheck and C.IdStatus=41 and Tho.IsReleased = 1 and Tho.IdStatus = @IdStatus)
			          else 0 end releasedCount,
                      C.CheckNumber, C.IssuerName, c.IdIdentificationType, c.IdentificationNumber, c.IdentificationDateOfExpiration, cu.SSNumber, c.DateOfBirth,  c.[CountryBirthId],
					   c.Ocupation ,
					   CU.IdOccupation,
					  CU.IdSubcategoryOccupation,
					  CU.SubcategoryOccupationOther,
					   c.RoutingNumber, C.Account, C.DateOfIssue,
					  COI.CustomerMatch,
					  COI.IssuerMatch,
					 U.UserName,
					 UT.Name AS UserType,
					 C.Name + ' ' + C.FirstLastName +  ' ' + C.SecondLastName as 'BeneficiaryName',
					 CU.Address,
					 CU.Zipcode,
					 CU.PhoneNumber,
					 CU.CelullarNumber,
					 CU.City,
					 CU.State,
					 CU.Country,
					 ISNULL(ISS.IdIssuer,0) IdIssuer,
					 ISNULL(ISS.PhoneNumber,'') IssuerPhone,
					 ISNULL(DLI.IdDenyListIssuerCheck,0) IdDenyListIssuerCheck,
					 ISNULL(DLI.IdGenericStatus, 0) IdGenericStatus,
					 ISNULL(C.BachCode, '') BachCode,
					 ISNULL(C.Comission,0) Comission,
					 ISNULL(C.Fee,0) Fee,
					 CASE WHEN (select COUNT(*) from CheckHolds where IdCheck = C.IdCheck AND IdStatus = 15 AND IsReleased = 1) >= 1 THEN 1 ELSE 0 END AS IsOfacMultiple,
			         C.MicrOriginal, 
					 C.MicrManual,


					 ISNULL(CPB.Name,'') CheckProcessorBank,
					 isnull(C.IsIRD, 0) AS 'IsIRD',
					 isnull(C.MicrEPC, '') AS 'MicrEPC',
					 isnull(C.MicrAuxOnUs, '') AS 'MicrAuxOnUs',
					 isnull(C.MicrOnUs, '') AS 'MicrOnUs'

					 
	   From [Checks] C with(nolock)
       inner join (select Distinct IdCheck, IdStatus, IsReleased FROM [CheckHolds]) CH ON CH.IdCheck = C.IdCheck
	   left join CheckProcessorBank CPB on CPB.IdCheckProcessorBank=C.IdCheckProcessorBank
       inner join [Agent] A with(nolock) on C.IdAgent = A.IdAgent
       inner join [Customer] CU with(nolock) on C.IdCustomer = CU.IdCustomer
       inner join [Status] S with(nolock) on CH.IdStatus = S.IdStatus
	   left join [dbo].[CheckOFACInfo] COI with(nolock) on COI.IdCheck = C.IdCheck
	   inner join [dbo].[Users] U with(nolock) on U.IdUser = C.EnteredByIdUser
	   inner join [dbo].[UsersType] UT with(nolock) on U.IdUserType = UT.IdUserType
	   left join [dbo].[IssuerChecks] ISS with(nolock) on ISS.IdIssuer = C.IdIssuer
	   --left join [dbo].[DenyListIssuerChecks] DLI with(nolock) on ISS.IdIssuer = DLI.IdIssuerCheck
	   left join (select distinct (select top 1 IdDenyListIssuerCheck from [DenyListIssuerChecks] where IdIssuerCheck = DLIC.IdIssuerCheck order by IdDenyListIssuerCheck desc) as IdDenyListIssuerCheck, IdIssuerCheck, IdGenericStatus from [dbo].[DenyListIssuerChecks] DLIC with(nolock)) DLI on ISS.IdIssuer = DLI.IdIssuerCheck
       left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT with(nolock) on DT.IdDocumentType=UF.IdDocumentType
                     where UF.IdStatus=1 and DT.IdType=1
                     group by UF.IdReference
              )LC on LC.IdReference=C.IdCustomer  
       left join 
       (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT with(nolock) on DT.IdDocumentType=UF.IdDocumentType
                     where UF.IdStatus=1 and DT.IdType=4
                     group by UF.IdReference
              )LT on LT.IdReference=C.IdCheck
       Where (C.IdStatus = 41 and CH.IdStatus = @IdStatus and CH.IsReleased is null) and 
	   (A.AgentCode like '%' + @Search  + '%'  or A.AgentName like '%' + @Search + '%' or CONVERT(Varchar, c.IdCheck) like '%' + @Search + '%' or @Search = '' or @Search is null)
       Order by  C.DateOfMovement   desc
End
else
begin
 Select top 1500 c.IdCheck, C.IdAgent,  A.AgentCode, C.Name, C.FirstLastName, C.SecondLastName, CU.PhysicalIdCopy  as CustomerPhysicalIdCopy,
                     A.AgentName, C.DateOfMovement, C.IdCheck, C.Amount, C.IdStatus, CASE when C.IdStatus=31 then 'Rejected'
				 else 'Accepted'end as StatusName,
                     C.IdCustomer, [dbo].[fun_GetLastReview](C.IdCheck) as LastReview
                     ,Convert(bit,case when LC.IdUploadFile is not null or LT.IdUploadFile is not null then 1 else 0 end) HasFiles,                     
			          case when @Idstatus = 15 then
			          (select count(1) from [CheckHolds]  Tho with(nolock) where Tho.IdCheck = C.IdCheck and C.IdStatus=41 and Tho.IsReleased = 1 and Tho.IdStatus = @IdStatus)
			          else 0 end releasedCount,
                      C.CheckNumber, C.IssuerName, c.IdIdentificationType, c.IdentificationNumber, c.IdentificationDateOfExpiration, cu.SSNumber, c.DateOfBirth,  c.[CountryBirthId], 
					  c.Ocupation ,
					  CU.IdOccupation,
					  CU.IdSubcategoryOccupation,
					  CU.SubcategoryOccupationOther,
					  c.RoutingNumber, C.Account, C.DateOfIssue,
					  COI.CustomerMatch,
					  COI.IssuerMatch,
					 U.UserName,
					 UT.Name AS UserType,
					 CU.Address,
					 CU.Zipcode,
					 CU.PhoneNumber,
					 CU.CelullarNumber,
					 CU.City,
					 CU.State,
					 CU.Country,
					 ISNULL(ISS.IdIssuer,0) IdIssuer,
					 ISNULL(ISS.PhoneNumber,'') IssuerPhone,
					 ISNULL(DLI.IdDenyListIssuerCheck,0) IdDenyListIssuerCheck,
					 ISNULL(DLI.IdGenericStatus, 0) IdGenericStatus,
					 C.Name + ' ' + C.FirstLastName +  ' ' + C.SecondLastName as 'BeneficiaryName',
					 ISNULL(C.BachCode, '') BachCode,
					 ISNULL(C.Comission,0) Comission,
					 ISNULL(C.Fee,0) Fee,
					  CASE WHEN (select COUNT(*) from CheckHolds where IdCheck = C.IdCheck AND IdStatus = 15 AND IsReleased = 1) >= 1 THEN 1 ELSE 0 END AS IsOfacMultiple,
					  C.MicrOriginal, 
					  C.MicrManual,
					   ISNULL(CPB.Name,'') CheckProcessorBank,
					   isnull(C.IsIRD, 0) AS 'IsIRD',
					   isnull(C.MicrEPC, '') AS 'MicrEPC',
					   isnull(C.MicrAuxOnUs, '') AS 'MicrAuxOnUs',
					   isnull(C.MicrOnUs, '') AS 'MicrOnUs'

	   From [Checks] C with(nolock)
       inner join (select Distinct IdCheck, IdStatus, IsReleased FROM [CheckHolds]) CH ON CH.IdCheck = C.IdCheck
	   left join CheckProcessorBank CPB on CPB.IdCheckProcessorBank=C.IdCheckProcessorBank
       inner join [Agent] A with(nolock) on C.IdAgent = A.IdAgent
       inner join [Customer] CU with(nolock) on C.IdCustomer = CU.IdCustomer
       inner join [Status] S with(nolock) on CH.IdStatus = S.IdStatus
	   inner join [dbo].[CheckOFACInfo] COI with(nolock) on COI.IdCheck = C.IdCheck
	   inner join [dbo].[Users] U with(nolock) on U.IdUser = C.EnteredByIdUser
	   inner join [dbo].[UsersType] UT with(nolock) on U.IdUserType = UT.IdUserType
	   left join [dbo].[IssuerChecks] ISS with(nolock) on ISS.IdIssuer = C.IdIssuer
	  -- left join [dbo].[DenyListIssuerChecks] DLI with(nolock) on ISS.IdIssuer = DLI.IdIssuerCheck
       left join (select distinct (select top 1 IdDenyListIssuerCheck from [DenyListIssuerChecks] where IdIssuerCheck = DLIC.IdIssuerCheck order by IdDenyListIssuerCheck desc) as IdDenyListIssuerCheck, IdIssuerCheck, IdGenericStatus from [dbo].[DenyListIssuerChecks] DLIC with(nolock)) DLI on ISS.IdIssuer = DLI.IdIssuerCheck
	   left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT with(nolock) on DT.IdDocumentType=UF.IdDocumentType
                     where UF.IdStatus=1 and DT.IdType=1
                     group by UF.IdReference
              )LC on LC.IdReference=C.IdCustomer  
       left join 
              (
                     select UF.IdReference, Max(UF.IdUploadFile) IdUploadFile
                     from UploadFiles UF with(nolock)
                           inner join DocumentTypes DT with(nolock) on DT.IdDocumentType=UF.IdDocumentType
                     where UF.IdStatus=1 and DT.IdType=4
                     group by UF.IdReference
              )LT on LT.IdReference=C.IdCheck
       Where ((C.IdStatus =41 and (CH.IsReleased=1 OR CH.IsReleased=0)) OR (C.IdStatus=31 and CH.IsReleased=0) and CH.IdStatus = @IdStatus and
	    Convert(date, C.DateOfMovement)>=Convert(date, @startDate)
		and Convert(date, C.DateOfMovement)<=Convert(date, @endDate)) and
	    (A.AgentCode like '%' + @Search  + '%'  or A.AgentName like '%' + @Search + '%' or CONVERT(Varchar, c.IdCheck) like '%' + @Search + '%' or @Search = '' or Convert(Varchar,C.CheckNumber) like '%'+@Search+'%' OR @Search IS NULL)
       Order by C.BachCode, C.DateOfMovement desc
	
end
End
Else -- If IdStatus is NOT a Hold use a simple search by IdStatus
Begin
       Select top 1500 C.IdAgent,  A.AgentCode, C.Name, C.FirstLastName, C.SecondLastName,
                     A.AgentName, C.DateOfMovement, C.IdCheck, C.Amount, C.IdStatus, S.StatusName,
                     CU.PhysicalIdCopy as CustomerPhysicalIdCopy, C.IdCustomer, NULL as LastReview
                     ,Convert(bit,0) HasFiles,
                     0 releasedCount
       From [Checks] C with(nolock)
       inner join [Agent] A with(nolock) on C.IdAgent = A.IdAgent
       inner join [Customer] CU with(nolock) on C.IdCustomer = C.IdCustomer
       inner join [Status] S with(nolock) on C.IdStatus = S.IdStatus
       Where C.IdStatus = @IdStatus
       Order by C.DateOfMovement desc
End
