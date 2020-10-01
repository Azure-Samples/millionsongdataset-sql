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

CREATE DATABASE [MillionSongDataset]
GO

ALTER DATABASE [MillionSongDataset] SET RECOVERY SIMPLE
GO

USE [MillionSongDataset]
GO

CREATE TABLE [dbo].[train_triplets](
	[UserId] [varchar](80) NULL,
	[SongId] [varchar](36) NULL,
	[ListenCount] [bigint] NULL,
	INDEX CCI_train_triplets CLUSTERED COLUMNSTORE
)
GO

CREATE TABLE [dbo].[unique_tracks](
	[TrackId] [varchar](50) NULL,
	[SongId] [varchar](50) NULL,
	[ArtistName] [nvarchar](500) NULL,
	[SongTitle] [nvarchar](500) NULL,
	INDEX CCI_unique_tracks CLUSTERED COLUMNSTORE
)
GO
