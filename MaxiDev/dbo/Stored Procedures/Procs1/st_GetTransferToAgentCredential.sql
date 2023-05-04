
CREATE procedure [dbo].[st_GetTransferToAgentCredential]
(
    @IdAgent int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and change subquery to variable</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

DECLARE @TransferToSSOPassword varchar(max),
        @TransferToClient varchar(max),
		@TransferToSessionUrl varchar(max), 
		@TransferToPublicKey varchar(max),
		@TransferToIP varchar(max)

SET @TransferToSSOPassword = (select Value from GlobalAttributes with(nolock) where Name = 'TransferToSSOPassword');
SET @TransferToClient = (select Value from GlobalAttributes with(nolock) where Name = 'TransferToClient');
SET @TransferToSessionUrl = (select Value from GlobalAttributes where Name = 'TransferToSessionUrl'); 
SET @TransferToPublicKey = (select Value from GlobalAttributes where Name = 'TransferToPublicKey'); 
SET @TransferToIP = (select Value from GlobalAttributes where Name = 'TransferToIP');

/*select username,
(select Value from GlobalAttributes with(nolock) where Name = 'TransferToSSOPassword') as TransferToSSOPassword, 
(select Value from GlobalAttributes with(nolock) where Name = 'TransferToClient') as TransferToClient, 
(select Value from GlobalAttributes where Name = 'TransferToSessionUrl') as TransferToSessionUrl, 
(select Value from GlobalAttributes where Name = 'TransferToPublicKey') as TransferToPublicKey, 
(select Value from GlobalAttributes where Name = 'TransferToIP') as TransferToIP 
from transferto.AgentCredential 
where idagent=@IdAgent and idgenericstatus=1*/

select username,
@TransferToSSOPassword as TransferToSSOPassword, 
@TransferToClient as TransferToClient, 
@TransferToSessionUrl as TransferToSessionUrl, 
@TransferToPublicKey as TransferToPublicKey, 
@TransferToIP as TransferToIP 
from transferto.AgentCredential with(nolock) 
where idagent=@IdAgent and idgenericstatus=1

--select * from transferto.AgentCredential