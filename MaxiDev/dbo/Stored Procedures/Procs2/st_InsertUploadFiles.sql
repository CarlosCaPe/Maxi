
CREATE procedure [dbo].[st_InsertUploadFiles]
(
    @UploadXML xml,
    @HasError bit out
)
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock)</log>
<log Date="16/04/2018" Author="jmolina">Se agrego log para validar el tipo de documento</log>
</ChangeLog>
********************************************************************/

DECLARE @DocHandle INT 
Declare @IdUploadFile Int
Declare 
    @Id Int,
    @IdReference int,
    @FileName nvarchar(max),
    @FileGuid nvarchar(max),
    @Extension nvarchar(max),
    @IdStatus int,
    @ExpirationDate date,
    @IdDocumentType int,
    @IdUser int,
    @IdDocumentImageType int,
    @LastChange_LastUserChange int,	
    @LastChange_LastDateChange datetime,
    @LastChange_LastIpChange	nvarchar(max),
    @LastChange_LastNoteChange nvarchar(max),
    @CreationDate datetime,
	@IdCountry int,
	@IdState int
	--@DateOfBirth datetime

Create Table #UploadFiles
(
    Id  int identity (1,1),
    IdReference int,
    [FileName] nvarchar(max),
    FileGuid nvarchar(max),
    Extension nvarchar(max),
    IdStatus int,
    ExpirationDate date,
    IdDocumentType int,
    IdUser int,
    IdDocumentImageType int,
    LastChange_LastUserChange int,	
    LastChange_LastDateChange datetime,
    LastChange_LastIpChange	nvarchar(max),
    LastChange_LastNoteChange nvarchar(max),
    CreationDate datetime,
	IdCountry int,
	IdState int
	--DateOfBirth datetime
)

begin try

EXEC sp_xml_preparedocument @DocHandle OUTPUT,@UploadXML 

DECLARE @DateOfBirth datetime

INSERT INTO #UploadFiles (IdReference, [FileName], FileGuid, Extension, IdStatus, ExpirationDate, IdDocumentType, IdUser, IdDocumentImageType, LastChange_LastUserChange, LastChange_LastDateChange, LastChange_LastIpChange, LastChange_LastNoteChange, CreationDate, IdCountry, IdState)
SELECT IdReference, [FileName], FileGuid, Extension, IdStatus, case when ExpirationDate = '01-01-1900' then null else ExpirationDate end, IdDocumentType, IdUser, IdDocumentImageType, LastChange_LastUserChange, LastChange_LastDateChange, LastChange_LastIpChange, LastChange_LastNoteChange, CreationDate, case when IdCountry = 0 then null else IdCountry end, case when IdState  = 0 then null else IdState  end
From OPENXML (@DocHandle, '/UploadFiles/UploadFile', 2)
    WITH (      
        IdReference INT,
        [FileName] nvarchar(max),
        FileGuid nvarchar(max),
        Extension nvarchar(max),
        IdStatus int,
        ExpirationDate date,
        IdDocumentType int,
        IdUser int,
        IdDocumentImageType int,
        LastChange_LastUserChange int,	
        LastChange_LastDateChange datetime,
        LastChange_LastIpChange	nvarchar(max),
        LastChange_LastNoteChange nvarchar(max),
        CreationDate datetime,
		IdCountry int,
		IdState int
    )

exec sp_xml_removedocument @DocHandle;

While exists (Select 1 from #UploadFiles WITH(NOLOCK))      
    BEGIN
        select top 1 
                @id=id,
                @IdReference=IdReference,
                @FileName=[FileName],
                @FileGuid=FileGuid,
                @Extension=Extension,
                @IdStatus=IdStatus,
                @ExpirationDate=ExpirationDate,
                @IdDocumentType=IdDocumentType,
                @IdUser=IdUser,
                @IdDocumentImageType=IdDocumentImageType,
                @LastChange_LastUserChange=LastChange_LastUserChange,
                @LastChange_LastDateChange=LastChange_LastDateChange,
                @LastChange_LastIpChange=LastChange_LastIpChange,
                @LastChange_LastNoteChange=LastChange_LastNoteChange,
                @CreationDate=CreationDate,
				@IdCountry = IdCountry,
				@IdState = IdState
        from 
            #UploadFiles WITH(NOLOCK)

		SELECT TOP 1 @DateOfBirth =  BornDate FROM [dbo].CUSTOMER WITH(NOLOCK) WHERE IDCUSTOMER = @IdReference
		--Log para verificar los datos por error en foreign key
		IF ISNULL(@IdDocumentType, 0) = 0
		BEGIN
			INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_InsertUploadFiles: @IdReference=' + CONVERT(VARCHAR, @IdReference)  + ', @FileName=' + @FileName + ', @IdDocumentType=' + CONVERT(VARCHAR, @IdDocumentType) + ', @IdDocumentImageType=' + CONVERT(VARCHAR, @IdDocumentImageType), GETDATE(), 'Error IdDocumentType en UploadFiles', '@UploadXML=' + CONVERT(varchar(max), @UploadXML))
		END

        IF NOT EXISTS (SELECT 1 FROM [dbo].[UploadFiles] with(nolock) WHERE [IdReference]=@IdReference AND IdDocumentType=@IdDocumentType AND [IdStatus]=@IdStatus AND [FileGuid]=@FileGuid AND Extension=@Extension)
        BEGIN

            IF ((select count(1)  from [dbo].UploadFiles with(nolock) where IdReference = @IdReference and IdDocumentType = 69) < 2 OR @LastChange_LastNoteChange ='This file comes from Transfer (Aditional info module)')
			begin

                INSERT INTO [dbo].[UploadFiles]
                   ([IdReference]
                   ,[IdDocumentType]
                   ,[FileName]
				   ,[FileGuid]
                   ,[Extension]
                   ,[IdStatus]
                   ,[IdUser]
                   ,[LastChange_LastUserChange]
                   ,[LastChange_LastDateChange]
                   ,[LastChange_LastIpChange]
                   ,[LastChange_LastNoteChange]
                   ,[ExpirationDate]
                   ,[CreationDate]
				   ,[DateOfBirth]
                   )
                VALUES
                   (
                   @IdReference,
                   @IdDocumentType,
                   @FileName,
                   @FileGuid,
                   @Extension,
                   @IdStatus,
                   @IdUser,
                   @LastChange_LastUserChange,
                   --@LastChange_LastDateChange, fix date
				   GETDATE(),
                   @LastChange_LastIpChange,
                   @LastChange_LastNoteChange,
                   @ExpirationDate,
                   @CreationDate,
				   @DateOfBirth
                   )

                set @IdUploadFile = SCOPE_IDENTITY()

        
                if (isnull(@IdDocumentImageType,0))>0
                begin
                    INSERT INTO [dbo].[UploadFilesDetail]
                        (   
                            [IdUploadFile],
					        [IdDocumentImageType],
					        [IdCountry],
					        [IdState]
                        )
                        VALUES
                        (
                            @IdUploadFile,
					        @IdDocumentImageType,
					        @IdCountry,
					        @IdState
                        )
                end
            END

        END

        delete from #UploadFiles where id=@id

		if(@IdDocumentType = 69)
		begin

			if((select count(1)  from [dbo].UploadFiles with(nolock) where IdReference = @IdReference and IdDocumentType = 69) = 2)
			begin
				 declare  @HasError2 bit,
						  @Message2 nvarchar(max)
						   select * from [dbo].[Status]
				   exec [Checks].[st_CheckUpdateVerifyHold] 37, 1, @IdReference, 'Check images process completed', 68, 1, @HasError2, @Message2
			end

		end

		--select * from DocumentTypes

    END

drop table #UploadFiles

set @HasError=0
end try
begin catch
set @HasError=1

    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_InsertUploadFiles',Getdate(),@ErrorMessage) 
	INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData) VALUES('st_InsertUploadFiles', GETDATE(), 'Error IdDocumentType en UploadFiles, Parametros: @IdReference=' + CONVERT(VARCHAR, @IdReference)  + ', @FileName=' + @FileName + ', @IdDocumentType=' + CONVERT(VARCHAR, @IdDocumentType) + ', @IdDocumentImageType=' + CONVERT(VARCHAR, @IdDocumentImageType), '@UploadXML=' + CONVERT(varchar(max), @UploadXML))
    DROP TABLE #UploadFiles
end catch

