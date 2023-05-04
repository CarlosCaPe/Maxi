CREATE TABLE [dbo].[MaxiCollectionAssigntmp] (
    [IdMaxiCollectionAssign] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT      NOT NULL,
    [IdUser]                 INT      NULL,
    [DateOfAssign]           DATETIME NOT NULL
);

