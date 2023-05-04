
CREATE PROCEDURE [BillPayment].[st_GetBillers]
   @IdAggregator int = null
    --, @IdBiller int = null
as

/********************************************************************
<Author>Amoreno</Author>
<app>MaxiCorp</app>
<Description>Optener Biller por Aggregator o todos</Description>

<ChangeLog>

<log Date="15/06/2018" Author="amoreno">Creation</log>
<log Date="20/06/2019" Author="azavala">Add Field ChoiseData and FixedFee to return data :: Ref: azavala_200620191240</log>
</ChangeLog>
*********************************************************************/

--set  @IdAggregator=1

 declare 
  @countStatesCountry int
  						

	   select @countStatesCountry= count(1)  from state where IdCountry=18		 
	   
	
	if(@IdAggregator=0)
	 set @IdAggregator=null				   



 select 
	  B.IdBiller
	  , B.Name
    , B.NameAggregator
	  , Aggregator = A.Name              	 
		, B.IdAggregator             
		, B.Posting	 
	  , B.PostingAggregator								 
		, B.BuyRate              		 
		, Relationship =
		                Case 
                     when  
                      B.Relationship ='' and B.Posting= 'Same Day Post'  		                                 
                     then 
                      'Autorized'
                     when
                       B.Relationship ='' 
                     then 
                      'Non Contracted'
                    else
                    B.Relationship
                   end
		, Presence =
		 				     	(  
		 					      case
		 					       when B.IsDomestic=1
		 					        then
		 					       		 case
		 					       		  when  (@countStatesCountry= (select count(1) from BillPayment.StateForBillers S where S.IdBiller= B.IdBiller and S.IdStatus=1))
		 					       		    then 
		 					               'National'
		 					             else
		 					              'Define'	 						 					 
		 					             end
		 					         when 
		 					          B.IsDomestic=0
		 					         then 
		 					          'International'
		 					       end
		 				      	)		 	 						 
		, B.CutOffTime							 
		, StatusBiller =
		                ( case
					 					 	 when  B.IdStatus=0
					 					 	  then 'New'
					 					 	  	 when  B.IdStatus=1
					 					 	  then 'Enabled'
					 					 	  	 when  B.IdStatus=2
					 					 	  then 'Disabled'					 				 
					 					 	end	
					 					 	)		
		, B.IdStatus
		, B.IdBillerOfClone   
		, NameBillerOfClone  = isnull ((select B2.Name  from   BillPayment.Billers B2 with (nolock) where B2.IdBiller=B.IdBillerOfClone), '')
		, DateOfCreation = isnull((select  min(L.DateLastChangue) from  BillPayment.LogForBillers L with (nolock) where L.IdBiller= B.IdBiller and L.Description='Status change 1' ), getdate())
		, DateOfCreationString =  isnull((select  cast( min(L.DateLastChangue) as nvarchar) from  BillPayment.LogForBillers L with (nolock) where L.IdBiller= B.IdBiller and L.Description='Status change 1' ), '')
		, B.IdBillerAggregator
		, B.Category
    , B.CategoryAggregator 
		, DateOfEdit = isnull((select cast( max(L.DateLastChangue) as nvarchar) from  BillPayment.LogForBillers L with (nolock) where L.IdBiller= B.IdBiller and L.MovementType='Update Info'), '')
		, DateOfStatusUpdate = isnull((select cast( max(L.DateLastChangue) as nvarchar) from  BillPayment.LogForBillers L with (nolock) where L.IdBiller= B.idBillerAggregator and L.MovementType='Update Status'), '')
		, isnull(ChoiseData,'') as ChoiseData --azavala_200620191240
		, IsFixedFee --azavala_200620191240
  from 
   BillPayment.Billers B with (nolock)
  inner join 
   BillPayment.Aggregator A with (nolock)
     on 
   A.IdAggregator = B.IdAggregator 
  where 
   B.IdAggregator  = isnull(@IdAggregator, B.IdAggregator)
   --and B.IdBiller= isnull( @IdBiller, B.IdBiller)


