create procedure st_getPureminutesDataForCancel
(
    @IdProductTransfer bigint
)
as
select PureMinutesUserID,PureMinutesTransID,IdAgent,ReceiveAmount,AgentCommission,fee,CorpCommission,ReceiveAccountNumber from pureminutestransaction where IdProductTransfer=@IdProductTransfer