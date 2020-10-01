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

USE MillionSongDataset
GO

SET STATISTICS io ON
GO

SET STATISTICS time ON
GO

-- Find songs which are similar to 'Just Dance' by Lady Gaga!
-- This query takes around 3 seconds to complete on a laptop with an i7 processor
-- For tuning this query performance, create clustered columnstore indexes! - see query 5_ImprovePerf.sql
SELECT
    TOP 10
    SimilarSong.SongTitle,
    COUNT(*)
FROM
    UniqueSong AS MySong,
    UniqueUser AS U,
    Likes AS LikesOther,
    Likes AS LikesThis,
    UniqueSong AS SimilarSong
WHERE MySong.SongTitle LIKE 'Just Dance'
    AND MATCH(SimilarSong<-(LikesOther)-U-(LikesThis)->MySong)
GROUP BY SimilarSong.SongTitle
ORDER BY COUNT(*) DESC

SET STATISTICS time OFF
GO

SET STATISTICS IO OFF
GO
