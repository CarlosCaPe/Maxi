CREATE procedure [Corp].[st_UpdateuserGroupAssigment]
 @IdGroup int 
 , @IdUserAssigned int 
 , @IdUserChange   int
 , @nota varchar(max)
as  


/*

    Fecha:          Autor         Comentario
-------------------------------------------------------------------------------------------------------------------------------------- 
 > 26 May 2017       JMoreno        Creación
 
 
 
  example:
  
    execute st_UpdateuserGroupAssigment 
	  @IdGroup = 32  
	 , @IdUserAssigned =9089  
	 , @IdUserChange  = 100
 		,@nota ='Cambio'
 
 
 */

declare 
 @guarcado int

begin 

--select IdUserAssign,* from   Collection.[Groups] 
	
	update 
	  Collection.[Groups] 
	set 
	 IdUserAssign= @IdUserAssigned
	where 
	 IdGroups= @IdGroup 

	
	select 
	 @guarcado=1 
	from 
	 Collection.[Groups] with (nolock)
	where 
	  IdGroups= @IdGroup 
    and IdUserAssign= @IdUserAssigned  

	if (@guarcado=1)
		begin 			

 
		INSERT INTO dbo.LogUserAssigment
				(
				IdUserAssigment,
				IdGroup, 
				IdUserLastChange,
				Nota,
				LastChangeDate,
				TypeChange
				)
			VALUES 
				(
				@IdUserAssigned,
				@IdGroup, 
				@IdUserChange,
				@Nota,
				getdate(),
				'Assignment'
				)

	
		end
    
    
select @guarcado as Guardado


end
