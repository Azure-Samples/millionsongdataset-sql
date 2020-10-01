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
NOTE - this sample has only been tested with SQL Server 2017+. It is not yet
tested with ML Services in Azure SQL Managed Instance.
*/

Use MillionSongDataset
GO

-- Here, we plot a 'relationship graph' for users who heard the song 'Kryptonite'.
-- The resultant PNG file shows a graph with users who heard this song, and also plots other songs they listened to.
-- To do this we are using SQL Server R Services and the 'igraph' package in R to render the graph as a PNG file
-- As a pre-requisite, you must have installed the 'igraph' package in R.exe
-- The documentation at https://docs.microsoft.com/en-us/sql/advanced-analytics/r/install-additional-r-packages-on-sql-server explains how to do this
-- Note: for SQL Server, you must modify the library path to use MSSQL14 instead of the MSSQL13 specified in the documentation
exec sp_execute_external_script @language = N'R',
@script = N'
require(igraph)

g <- graph.data.frame(graphdf)

V(g)$label.cex <- 2

png(filename = "c:\\MSD\\plot1.png", height = 6000, width = 6000, res = 100);
plot(g, vertex.label.family = "sans", vertex.size = 5)
dev.off()
',
@input_data_1 = N'select distinct LEFT(UserId, 5) as UserId, LEFT(REPLACE(ArtistName, '' '', ''''), 15) as ArtistName
            from
            (
            select TOP 500 U.UserId, SimilarSong.ArtistName, ROW_NUMBER() OVER(PARTITION BY UserId ORDER BY LikesOther.ListenCount desc) as RowNum
            from UniqueSong as MySong,
            UniqueUser as U,
            Likes as LikesOther,
            Likes as LikesThis,
            UniqueSong as SimilarSong
            where MySong.SongTitle = ''Kryptonite''
            and MATCH(SimilarSong<-(LikesOther)-U-(LikesThis)->MySong)
            ) as InnerTable
            where RowNum <= 20
            order by UserId',
@input_data_1_name = N'graphdf'
GO