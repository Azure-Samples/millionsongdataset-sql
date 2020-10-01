/*
Importing and using the Million Song Dataset (https://labrosa.ee.columbia.edu/millionsong/) in Azure SQL DB / SQL Server

Citation:
Thierry Bertin-Mahieux, Daniel P.W. Ellis, Brian Whitman, and Paul Lamere.
The Million Song Dataset. In Proceedings of the 12th International Society
for Music Information Retrieval Conference (ISMIR 2011), 2011.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

This sample code is not supported under any Microsoft standard support program or service.
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts
be liable for any damages whatsoever (including, without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
*/

/*
	Create a "Connections" table to define a social graph,
	as the original Million Songs datasets doesn't provide
	connections between users.
*/
DROP TABLE IF EXISTS [dbo].[Connections];
CREATE TABLE [dbo].[Connections] (ListenCount INT) AS EDGE;
GO

INSERT INTO
	[dbo].[Connections] ($from_id, $to_id, ListenCount)
SELECT
	[u1].$node_id,
	[u2].$node_id,
	l2.[ListenCount]
FROM
	[dbo].[UniqueUser] [u1], [dbo].[Likes] [l1], [dbo].[UniqueUser] [u2], [dbo].[UniqueSong] [s], [dbo].[Likes] [l2]
WHERE
	MATCH(u1-(l1)->s<-(l2)-u2)
AND
	[l1].[ListenCount] > 150
AND
	[l2].[ListenCount] > 300
AND
	[u1].[UserId] != [u2].[UserId];
GO

/*
	Create columnstore index to support
	aggregations over the social network data
*/
DROP INDEX IF EXISTS [ixc] ON [dbo].[Connections];
CREATE CLUSTERED COLUMNSTORE INDEX [ixc] ON [dbo].[Connections];
GO

/*
	Take peek at how and "edge" table keep tracks
	of who is connected to whom
*/
SELECT TOP (100)
	$from_id,
	$to_id,
	[FromUserId] = JSON_VALUE($from_id, '$.id'),
	[ToUserId] = JSON_VALUE($to_id, '$.id')
FROM
	[dbo].[Connections];
GO

/*
	Find the influencers

	Match us a syntax close the Cypher:

	u1(-(C)->u2)+

	means: take a user (u1) and find all connected (C) users (u2) directly or indirectly via other users (+)
*/
WITH cte AS
(
	SELECT
		[u1].[UserId],
		STRING_AGG([u2].[UserId], '->') WITHIN GROUP (GRAPH PATH) AS [Connections],
		SUM(c.ListenCount)  WITHIN GROUP (GRAPH PATH) AS ListenCount,
		COUNT([u2].[UserId]) WITHIN GROUP (GRAPH PATH) AS Distance,
		LAST_VALUE(u2.UserId) WITHIN GROUP (GRAPH PATH) AS InfluencedUser
	FROM
		dbo.UniqueUser u1, dbo.Connections FOR PATH C, dbo.UniqueUser FOR PATH u2
	WHERE
		MATCH(
			SHORTEST_PATH(
				u1(-(C)->u2)+
			)
		)
)
SELECT
	UserId,
	COUNT(*) AS Influenced,
	SUM(ListenCount) AS InfluencedListenCount,
	AVG(Distance * 1.) AS AverangeDistance,
	MAX(Distance) AS MaxDistance
FROM
	cte
GROUP BY
	UserId
ORDER BY
	[Influenced] DESC
OPTION
	(HASH JOIN)
GO
