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

-- This (node) table holds the main details of the song
CREATE TABLE UniqueSong
(
	SongId     VARCHAR(50),
	SongTitle  VARCHAR(500),
	ArtistName NVARCHAR(500)
	)
AS Node
GO

-- This (node) table holds the user IDs. We do not have (nor do we need, for this demo) any other details about the user
CREATE TABLE UniqueUser
(
	UserId VARCHAR(80)
)
AS node
GO

-- This edge table stores the relationships - see the 'ConvertData' script on how the 'from' (user) and 'to' (song) are specified,
-- and an attribute (ListenCount) on the edge which stores the number of times the user listened to this song.
CREATE TABLE Likes
(
	ListenCount BIGINT
)
AS Edge
GO
