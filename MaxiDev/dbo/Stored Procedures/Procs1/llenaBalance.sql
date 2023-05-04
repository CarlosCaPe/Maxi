 
 
 CREATE procedure llenaBalance    
 as    
  set nocount on  
 Declare @IdAgent INT    
 Declare @Balance MONEY     
 Set @IdAgent=0    
 Set @Balance=0 
 
 Create table  #temp
 (
 Id int identity(1,1),
 IdAgent int
 ) 
 
 Insert into #temp (IdAgent)   
 Select distinct  IdAgent  From AgentBalance order by IdAgent 
   
 Create nonclustered index indextemporal2 on #temp (Id)   
    
     
 Declare @IdAgentBalance int    
 Declare @Amount money    
 Declare @DebitOrCredit nvarchar(max)  
 Declare @Contador int  
 Declare @ContadorPrincipal int  
    
    
 Set  @ContadorPrincipal=1  
     
 While exists (Select 1 from #temp where Id=@ContadorPrincipal )    
 Begin    
    Select  @IdAgent=IdAgent from #temp where Id=@ContadorPrincipal     
     
          Select @Balance=Balance from  AgentCurrentBalance where IdAgent=@IdAgent
          
          Create table  #temp2
          (
          Id int identity(1,1),
          IdAgentBalance int,
          DebitOrCredit nvarchar(max),
          Amount money
          )   
          
          Insert into #temp2 (IdAgentBalance,DebitOrCredit,Amount)   
          Select IdAgentBalance,DebitOrCredit,Amount from AgentBalance where IdAgent=@IdAgent order by DateOfMovement
              
          Create nonclustered index indextemporal on #temp2 (IdAgentBalance)  
          Set @Contador=1
             
          While exists (Select top 1 1 from #temp2 where ID=@Contador )    
          BEGIN    
						Select  @IdAgentBalance=IdAgentBalance,@Amount=Amount,@DebitOrCredit=DebitOrCredit from #temp2 where ID=@Contador    
					        
						if @DebitOrCredit='Debit'     
						 Set @Balance=@Balance+@Amount    
						else    
						 Set @Balance=@Balance-@Amount    
					          
						Update AgentBalance set Balance=@Balance where IdAgentBalance=@IdAgentBalance    
					        
						Set @Contador=@Contador+1  
          END    
       Drop table #temp2 
       
    set @ContadorPrincipal =@ContadorPrincipal+1  
 End    
     

