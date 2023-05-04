CREATE TABLE [dbo].[TransfersUnclaimed] (
    [IdTransfer] INT NOT NULL,
    [IdStatus]   INT NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161219-130740]
    ON [dbo].[TransfersUnclaimed]([IdTransfer] ASC);

