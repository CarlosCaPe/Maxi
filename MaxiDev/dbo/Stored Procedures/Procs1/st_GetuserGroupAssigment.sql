
CREATE procedure [dbo].[st_GetuserGroupAssigment]  
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
  Users Rs

 inner join 
    dbo.CollectionUsers Co  
 on 
  Co.IdUser=Rs.IdUser
 where 
   Rs.IdGenericStatus=1
 order  by  Rs.UserName
end


