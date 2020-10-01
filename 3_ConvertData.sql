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

Use MillionSongDataset;
GO

-- This step inserts the songs into the Node table (UniqueSong), which internally generates a unique $node_id pseudo-column per row
INSERT UniqueSong (SongId, SongTitle, ArtistName)
SELECT DISTINCT
    SongId,
    SongTitle,
    ArtistName
FROM unique_tracks
GO

-- This step inserts the users into the Node table (UniqueUser), which internally generates a unique $node_id pseudo-column per row
INSERT UniqueUser (UserId)
SELECT DISTINCT UserId
FROM dbo.train_triplets
GO

-- This step inserts the from and to relationships between users and songs. To do this, it uses the previously generated $node_id values
-- for each user and each song, and then inserts those along with the ListenCount for that relationship into the Likes table
-- Note the use of $from_id and $to_id. These are pseudo-columns which allow the edge table to track relationships correctly.
INSERT Likes
    ($from_id, $to_id, ListenCount)
SELECT
    U.$node_id,
    S.$node_id,
    T.ListenCount
FROM
    dbo.train_triplets T
    JOIN UniqueUser U ON U.UserId = T.UserId
    JOIN UniqueSong S ON T.SongId = S.SongId
GO

-- let's sample the data now!
-- Note the $node_id column (represented as a JSON string) in the output
SELECT    TOP (10)    *
FROM    UniqueUser;

-- Note the $node_id column (represented as a JSON string) in the output
SELECT    TOP (10)    *
FROM    UniqueSong;

-- Note the $edge_id, $from_id, $to_id pseudo-columns (each represented as a JSON string) in the output
SELECT    TOP (10)    *
FROM    Likes;
