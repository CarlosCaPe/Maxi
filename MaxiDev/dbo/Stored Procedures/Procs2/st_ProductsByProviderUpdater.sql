Create procedure [dbo].[st_ProductsByProviderUpdater]
as
Set nocount on 
----------------------------------- a Borrar idGenerciStatus=2 --------------
Update ProductsByProvider set idGenericStatus=2 
where '1|'+convert(varchar,IdGroup)+'|'+VendorName+'|'+VendorID  not in
(
Select '1|'+convert(varchar,IdGroups)+'|'+VendorName+'|'+VendorID  
From
(
Select  Distinct VendorName,VendorID,VendorSubtype  from softgate.billers
) A
Left Join Groups b on (A.VendorSubtype=B.VendorSubtype)
)
------------------------------- A insertar idGenerciStatus=1-------------------------------
Insert into ProductsByProvider (IdProvider,IdGroup,VendorName,VendorID,IdGenericStatus)
Select 1,IdGroups,VendorName,VendorID,1
From
(
Select  Distinct VendorName,VendorID,VendorSubtype  from softgate.billers
) A
Left Join Groups b on (A.VendorSubtype=B.VendorSubtype)
Where '1|'+convert(varchar,IdGroups)+'|'+VendorName+'|'+VendorID  not in 
(
Select '1|'+convert(varchar,IdGroup)+'|'+VendorName+'|'+VendorID from ProductsByProvider
)
----------------------------------------------------------------------------
