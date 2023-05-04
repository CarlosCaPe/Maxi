CREATE procedure [Corp].[st_GetuserGroupAssigment]  
as  


/*

    Fecha:          Autor         Comentario
-------------------------------------------------------------------------------------------------------------------------------------- 
 > 26 May 2017       JMoreno        Creación
 
 
 
  example:
  
    execute st_GetuserGroupAssigment 

 
 */

begin

 select
  Rs.IdUser
  , Rs.UserName
 from 
  Users Rs with (nolock)

 inner join 
    dbo.CollectionUsers Co with (nolock) 
 on 
  Co.IdUser=Rs.IdUser
 where 
   Rs.IdGenericStatus=1
 order  by  Rs.UserName
end
