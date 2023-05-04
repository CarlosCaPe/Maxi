
CREATE procedure [dbo].[st_GetLogUserAssigment]  
  @IdGroup int

as  
  
/*

    Fecha:          Autor         Comentario
-------------------------------------------------------------------------------------------------------------------------------------- 
 >  25 May 2017       JMoreno        Se modifica de que la consulta se en vez de 1 mes 3 años.
 
 
 
  example:
  
    execute st_GetLogUserAssigment 
    @IdGroup=31
 
 */


begin
 select 
  [UserAssigment] = 
                   (select 
                     UserName  
                    from 
                     Users Urs
                     where 
                      Urs.IdUser=La.IdUserAssigment                   
                   )
  , [UserChange]  =
   							  (select 
                     UserName  
                    from 
                     Users Urs
                     where 
                      Urs.IdUser=La.IdUserLastChange                   
                   )
  , [DateChange]  = La.LastChangeDate
  , [Note]        = La.Nota
  , [TypeChange]	= TypeChange

                 
 from 
  [MAXILOG].[dbo].LogUserAssigment La   
 where 
  IdGroup = @IdGroup
 order by La.LastChangeDate asc

end





