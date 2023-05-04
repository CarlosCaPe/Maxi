CREATE TABLE [Corp].[OfacValidationReviewHistory] (
    [IdOfacValidationReviewHistory] INT      IDENTITY (1, 1) NOT NULL,
    [IdOfacValidationDetail]        INT      NULL,
    [IdUser]                        INT      NULL,
    [DateOfReview]                  DATETIME NULL,
    CONSTRAINT [PK_IdOfacValidationReviewHistory] PRIMARY KEY CLUSTERED ([IdOfacValidationReviewHistory] ASC)
);

