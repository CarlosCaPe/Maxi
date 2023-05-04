--exec st_CustomerBlackListRemoveTask
CREATE procedure [dbo].[st_CustomerBlackListRemoveTask]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
declare @IdUser int

set @IdUser=dbo.GetGlobalAttributeByName('SystemUserID')

--select @IdUser

update customerblacklist set idgenericstatus=2,dateoflastchange=getdate(),enterbyiduser=@IdUser where IdCustomerBlackList in
(select IdCustomerBlackList from customerblacklist WITH(NOLOCK) where idgenericstatus=1 and DATEADD(minute,-1,dbo.RemoveTimeFromDatetime(DateOfCreation)+convert(int,dbo.GetGlobalAttributeByName('TimeInCustomerBlackList')))<getdate())