CREATE TABLE [dbo].[ScaleRounding] (
    [IdScaleRounding] BIGINT       IDENTITY (1, 1) NOT NULL,
    [ScaleRName]      VARCHAR (20) NOT NULL,
    CONSTRAINT [Pk_ScaleRounding] PRIMARY KEY CLUSTERED ([IdScaleRounding] ASC)
);

