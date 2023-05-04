
CREATE procedure [dbo].[st_PendingNotifications]
(@RegisteredUsers XML)
as


       declare  @DocHandle INT 
       EXEC sp_xml_preparedocument @DocHandle OUTPUT,@RegisteredUsers

       SELECT
       IdUser,
       LTRIM(RTRIM(ISNULL(UserSession,''))) UserSession,
       LTRIM(RTRIM(ISNULL(ConnectionId,''))) ConnectionId
       into #TempUsers
       FROM OPENXML (@DocHandle, '/Users/User',2)
       With (
                    IdUser int,
                    UserSession varchar(500),
                    ConnectionId varchar(500)
       )

       --Select TU.ConnectionId
       --from #TempUsers TU
       --Where TU.IdUser in (8032)

       Select top 100 ConnectionId
       FROM
             (
                    select distinct TU.ConnectionId
                    from msg.Messages M with (nolock)
                           Inner Join msg.MessageSubcribers MS with (nolock) on M.IdMessage = MS.IdMessage 
                           inner join Users U (nolock) on U.IdUser =MS.IdUser and U.IdUserType=2
                           inner join UsersSession US with (nolock) on MS.IdUser=US.IdUser
                           inner join #TempUsers TU on US.IdUser=TU.IdUser and US.SessionGuid=TU.UserSession
                    where MS.IdMessageStatus=1
             )L 
       
       
