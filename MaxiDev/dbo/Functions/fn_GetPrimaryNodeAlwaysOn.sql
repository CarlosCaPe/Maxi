

create FUNCTION dbo.fn_GetPrimaryNodeAlwaysOn()-- ( @AGName sysname )
RETURNS INT
AS
BEGIN
-----------
	IF ( (SERVERPROPERTY ('IsHadrEnabled') = 1) AND 
	     ( SELECT coalesce(AGC.name, ARS.role_desc ,'0')
		   FROM sys.availability_groups_cluster AS AGC
		  INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS RCS ON RCS.group_id = AGC.group_id
		  INNER JOIN sys.dm_hadr_availability_replica_states AS ARS ON ARS.replica_id = RCS.replica_id
		  INNER JOIN sys.availability_group_listeners AS AGL ON AGL.group_id = ARS.group_id
		  WHERE ARS.role_desc = 'PRIMARY') != '0'
	    )
		BEGIN		
				RETURN 1; 
		END
-----------
		ELSE 
			BEGIN
			  RETURN 0;
			END
	
	RETURN 0;

END
