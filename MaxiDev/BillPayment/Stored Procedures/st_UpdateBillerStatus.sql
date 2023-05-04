
CREATE PROCEDURE [BillPayment].[st_UpdateBillerStatus]
	@IdBiller int --200620191732_azavala
   , @idBillerAggregator int 
   , @IdAggregator int
   , @IdStatus int
   , @IdUser int
   , @ChoiseData nvarchar(150) --200620191732_azavala
   , @HasError int out
   , @Message nvarchar(max) out
as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Actualizar el Status del Biller</Description>

<ChangeLog>
<log Date="20/06/2018" Author="amoreno">Creation</log>
<log Date="20/06/2019" Author="azavala">Add Parameters as IdBiller and ChoiseData to identify the correct biller for the new Fiserv's Process:: Ref: 200620191732_azavala</log>
</ChangeLog>
*********************************************************************/


begin try 
	--insert into ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) values ('BillPayment.st_UpdateBillerStatus', GETDATE(), 'IdBiller: ' + Convert(varchar(max), @IdBiller) + '; IdBillerAggregator: ' + Convert(varchar(max), @idBillerAggregator) + '; ChoiseData: ' + @ChoiseData)

	UPDATE  
	 BillPayment.Billers 
	SET 
	 IdStatus=@IdStatus
	WHERE 
	   idBillerAggregator=@idBillerAggregator
	   and IdBiller = @IdBiller --200620191732_azavala
	   and IdAggregator= @IdAggregator
	   --and ChoiseData = @ChoiseData --200620191732_azavala
	 	 
	   
insert into 
  BillPayment.LogForBillers	
   ( IdBiller	
     , IdUser
     , MovementType
     , DateLastChangue
     , Description
    )
  Values 
	 ( @IdBiller
	   , @IdUser
	   , 'Update Status'
	   , Getdate()
	   , 'Status change' +' ' + CAST(@IdStatus as nvarchar(20))
	  )
		  		 	  	   
		  
End Try
Begin Catch 
 set @HasError = 1
 set @Message='Error'
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateBillerStatus',Getdate(),ERROR_MESSAGE())    
End Catch		  
