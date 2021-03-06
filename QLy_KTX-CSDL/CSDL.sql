USE [QUANLYKYTUCXA]
GO
/****** Object:  StoredProcedure [dbo].[pr_DienNuoc]    Script Date: 30/6/2021 10:33:56 AM ******/
DROP PROCEDURE [dbo].[pr_DienNuoc]
GO
/****** Object:  StoredProcedure [dbo].[cau9]    Script Date: 30/6/2021 10:33:56 AM ******/
DROP PROCEDURE [dbo].[cau9]
GO
/****** Object:  StoredProcedure [dbo].[cau8]    Script Date: 30/6/2021 10:33:56 AM ******/
DROP PROCEDURE [dbo].[cau8]
GO
ALTER TABLE [dbo].[SinhVien] DROP CONSTRAINT [chk_SinhVien_Gioitinh]
GO
ALTER TABLE [dbo].[Phong] DROP CONSTRAINT [chk_Phong_SoLuongSV]
GO
ALTER TABLE [dbo].[Phong] DROP CONSTRAINT [chk_Phong_LoaiPhong]
GO
ALTER TABLE [dbo].[HopDong] DROP CONSTRAINT [chk_HopDong_Ngaylap]
GO
ALTER TABLE [dbo].[HopDong] DROP CONSTRAINT [chk_HopDong_NgayBDvaKT]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] DROP CONSTRAINT [chk_HoaDonDienNuoc_hdNuoc]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] DROP CONSTRAINT [chk_HoaDonDienNuoc_hdDien]
GO
ALTER TABLE [dbo].[HopDong] DROP CONSTRAINT [FK_HopDong_SinhVien]
GO
ALTER TABLE [dbo].[HopDong] DROP CONSTRAINT [FK_HopDong_QuanLy]
GO
ALTER TABLE [dbo].[HopDong] DROP CONSTRAINT [FK_HopDong_Phong]
GO
ALTER TABLE [dbo].[HoaDonPhong] DROP CONSTRAINT [FK_HoaDonPhong_SinhVien]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] DROP CONSTRAINT [FK_HoaDonDienNuoc_QuanLy]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] DROP CONSTRAINT [FK_HoaDonDienNuoc_Phong]
GO
/****** Object:  Table [dbo].[SinhVien]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP TABLE [dbo].[SinhVien]
GO
/****** Object:  Table [dbo].[QuanLy]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP TABLE [dbo].[QuanLy]
GO
/****** Object:  Table [dbo].[Phong]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP TABLE [dbo].[Phong]
GO
/****** Object:  Table [dbo].[HopDong]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP TABLE [dbo].[HopDong]
GO
/****** Object:  Table [dbo].[HoaDonPhong]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP TABLE [dbo].[HoaDonPhong]
GO
/****** Object:  Table [dbo].[HoaDonDienNuoc]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP TABLE [dbo].[HoaDonDienNuoc]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TongTienThu]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP FUNCTION [dbo].[FN_TongTienThu]
GO
/****** Object:  UserDefinedFunction [dbo].[cau10]    Script Date: 30/6/2021 10:33:57 AM ******/
DROP FUNCTION [dbo].[cau10]
GO
/****** Object:  UserDefinedFunction [dbo].[cau10]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[cau10]
(
	@gioitinh varchar(20),
	@maphong varchar(10)
) RETURNS Nchar(10)
AS
 BEGIN
	DECLARE @kq Nchar(10)
	DECLARE @loaiphong NVARCHAR(3)
	DECLARE @soluongsv int
	DECLARE @tinhtrangphong bit

	SELECT @loaiphong = LoaiPhong FROM Phong WHERE Maphong = @maphong
	SELECT @soluongsv = SoluongSV FROM Phong WHERE Maphong = @maphong
	SELECT @tinhtrangphong = TinhTrang FROM Phong WHERE Maphong = @maphong
	
	--Nếu tình trạng phòng là true(Có thể cho sv vào ở)
	IF(@tinhtrangphong='True')
		BEGIN
			--Phòng chưa có sv nào thì cho ở luôn
			IF(@soluongsv=0)
				SET @kq='OK'
			--Nếu phòng đang có sv ở thì xét xem giới tính có phù hợp k
			IF(@soluongsv>0 and @soluongsv<8)
			begin
				IF(@gioitinh = N'nam')
				begin
					IF(@loaiphong = N'nam')
						SET @kq = 'OK'
					IF(@loaiphong = N'nữ')
						SET @kq = 'NOT OK'
				end
				IF(@gioitinh = N'nữ')
				begin
					IF(@loaiphong = N'nam')
						SET @kq = 'NOT OK'
					IF(@loaiphong = N'nữ')
						SET @kq = 'OK'
				end
			end
		END
	--Tình trạng phòng false(Có thể là k đảm bảo cơ sở vật chất hoặc đã full giường)
	ELSE
		begin
			SET @kq='NOT OK'
		end
	RETURN @kq
 END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TongTienThu]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FN_TongTienThu](
	@thang varchar(7)
)
RETURNS MONEY 
AS BEGIN

	DECLARE @TongTienDienNuoc money;
	DECLARE @TongTienPhong money;
	--Tính tổng tiền điện nước thu được của tháng đó
	IF(NOT EXISTS (SELECT * FROM HoaDonDienNuoc WHERE Thang=@thang))
		SET @TongTienDienNuoc = 0;
	ELSE
		begin
			SELECT @TongTienDienNuoc=Sum(Tongtien)
			FROM HoaDonDienNuoc
			WHERE Thang=@thang; 
		end
	--Tính tổng tiền phòng thu được của tháng đó
	IF(NOT EXISTS (SELECT * FROM HoaDonPhong WHERE Thang=@thang))
		SET @TongTienPhong = 0;
	ELSE
		begin
			SELECT @TongTienPhong=Sum(Sotien)
			FROM HoaDonPhong
			WHERE Thang=@thang; 
		end
	--trả về Tổng tiền thu được ở cả 2 hóa đơn
	RETURN @TongTienDienNuoc+@TongTienPhong;
END
GO
/****** Object:  Table [dbo].[HoaDonDienNuoc]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HoaDonDienNuoc](
	[Mahoadon] [int] NOT NULL,
	[Maquanly] [varchar](20) NOT NULL,
	[Maphong] [varchar](10) NOT NULL,
	[Ngaylap] [date] NULL CONSTRAINT [DF_HoaDonDienNuoc_Ngaylap]  DEFAULT (getdate()),
	[Thang] [varchar](7) NOT NULL,
	[CSDdien] [int] NULL,
	[CSCdien] [int] NULL,
	[CSDnuoc] [int] NULL,
	[CSCnuoc] [int] NULL,
	[Tongtien] [money] NOT NULL,
 CONSTRAINT [PK_HoaDonDienNuoc] PRIMARY KEY CLUSTERED 
(
	[Mahoadon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HoaDonPhong]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HoaDonPhong](
	[Mahoadon] [int] NOT NULL,
	[Masv] [varchar](20) NOT NULL,
	[MaPhong] [varchar](10) NOT NULL,
	[Thang] [varchar](7) NOT NULL,
	[Sotien] [money] NOT NULL,
	[Ngaylap] [date] NULL CONSTRAINT [DF_HoaDonPhong_Ngaylap]  DEFAULT (getdate()),
 CONSTRAINT [PK_HoaDonPhong] PRIMARY KEY CLUSTERED 
(
	[Mahoadon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HopDong]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HopDong](
	[Mahopdong] [varchar](20) NOT NULL,
	[Masv] [varchar](20) NOT NULL,
	[Maquanly] [varchar](20) NOT NULL,
	[Maphong] [varchar](10) NOT NULL,
	[Ngaylap] [date] NULL,
	[Ngaybatdau] [date] NULL,
	[Ngayketthuc] [date] NULL,
 CONSTRAINT [PK_HopDong] PRIMARY KEY CLUSTERED 
(
	[Mahopdong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Phong]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Phong](
	[Maphong] [varchar](10) NOT NULL,
	[Sophong] [int] NULL,
	[Khunha] [char](3) NULL,
	[LoaiPhong] [nvarchar](3) NULL,
	[SoluongSV] [int] NOT NULL,
	[TinhTrang] [bit] NOT NULL,
 CONSTRAINT [PK_Phong] PRIMARY KEY CLUSTERED 
(
	[Maphong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[QuanLy]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[QuanLy](
	[Maquanly] [varchar](20) NOT NULL,
	[Hoten] [nvarchar](50) NULL,
	[Ngaysinh] [date] NULL,
	[Diachi] [nvarchar](50) NULL,
	[SDT] [varchar](20) NULL,
 CONSTRAINT [Pk_QuanLy] PRIMARY KEY CLUSTERED 
(
	[Maquanly] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SinhVien]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SinhVien](
	[Masv] [varchar](20) NOT NULL,
	[Hodem] [nvarchar](20) NULL,
	[Ten] [nvarchar](50) NULL,
	[Ngaysinh] [date] NULL,
	[GioiTinh] [nvarchar](3) NOT NULL,
	[CMND] [varchar](20) NULL,
	[SDT] [varchar](20) NULL,
	[Khoa] [nvarchar](20) NULL,
	[Lop] [varchar](10) NULL,
 CONSTRAINT [Pk_SinhVien] PRIMARY KEY CLUSTERED 
(
	[Masv] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[HoaDonDienNuoc] ([Mahoadon], [Maquanly], [Maphong], [Ngaylap], [Thang], [CSDdien], [CSCdien], [CSDnuoc], [CSCnuoc], [Tongtien]) VALUES (1, N'ql02', N'a1406', CAST(N'2021-06-22' AS Date), N'5/2021', 56, 78, 34, 38, 399.0000)
INSERT [dbo].[HoaDonDienNuoc] ([Mahoadon], [Maquanly], [Maphong], [Ngaylap], [Thang], [CSDdien], [CSCdien], [CSDnuoc], [CSCnuoc], [Tongtien]) VALUES (2, N'ql01', N'k4105', CAST(N'2021-06-24' AS Date), N'4/2021', 74, 89, 52, 60, 425.0000)
INSERT [dbo].[HoaDonDienNuoc] ([Mahoadon], [Maquanly], [Maphong], [Ngaylap], [Thang], [CSDdien], [CSCdien], [CSDnuoc], [CSCnuoc], [Tongtien]) VALUES (3, N'ql01', N'k4105', CAST(N'2021-06-24' AS Date), N'5/2021', 89, 104, 60, 71, 399.0000)
INSERT [dbo].[HoaDonDienNuoc] ([Mahoadon], [Maquanly], [Maphong], [Ngaylap], [Thang], [CSDdien], [CSCdien], [CSDnuoc], [CSCnuoc], [Tongtien]) VALUES (4, N'ql03', N'k5101', CAST(N'2021-06-24' AS Date), N'4/2021', 29, 44, 59, 68, 289.0000)
INSERT [dbo].[HoaDonPhong] ([Mahoadon], [Masv], [MaPhong], [Thang], [Sotien], [Ngaylap]) VALUES (1, N'K1854801', N'a1406', N'5/2021', 300.0000, CAST(N'2021-06-24' AS Date))
INSERT [dbo].[HoaDonPhong] ([Mahoadon], [Masv], [MaPhong], [Thang], [Sotien], [Ngaylap]) VALUES (2, N'K1854806', N'k5101', N'4/2021', 200.0000, CAST(N'2021-06-24' AS Date))
INSERT [dbo].[HoaDonPhong] ([Mahoadon], [Masv], [MaPhong], [Thang], [Sotien], [Ngaylap]) VALUES (3, N'K1854804', N'a1407', N'5/2021', 100.0000, CAST(N'2021-06-24' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd01', N'K1854801', N'ql02', N'a1406', CAST(N'2021-05-22' AS Date), CAST(N'2021-06-01' AS Date), CAST(N'2021-07-30' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd02', N'K1855806', N'ql01', N'k4105', CAST(N'2021-02-28' AS Date), CAST(N'2021-03-01' AS Date), CAST(N'2021-05-30' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd03', N'K1854806', N'ql03', N'k5101', CAST(N'2021-01-24' AS Date), CAST(N'2021-02-01' AS Date), CAST(N'2021-05-30' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd04', N'K1854804', N'ql02', N'a1407', CAST(N'2021-04-30' AS Date), CAST(N'2021-05-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd05', N'K1854803', N'ql03', N'k2412', CAST(N'2021-06-24' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd06', N'K1855804', N'ql02', N'a1406', CAST(N'2021-06-30' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd07', N'K1854810', N'ql03', N'k5202', CAST(N'2021-06-24' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd08', N'K1855801', N'ql02', N'a1406', CAST(N'2021-06-29' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd10', N'K1854809', N'ql03', N'k2412', CAST(N'2021-06-29' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd11', N'K1855808', N'ql03', N'k2412', CAST(N'2021-06-29' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-30' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd12', N'K1854806', N'ql01', N'k4105', CAST(N'2021-02-28' AS Date), CAST(N'2021-03-01' AS Date), CAST(N'2021-05-30' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd13', N'K1855809', N'ql02', N'a1409', CAST(N'2021-06-29' AS Date), CAST(N'2021-07-01' AS Date), CAST(N'2021-07-31' AS Date))
INSERT [dbo].[HopDong] ([Mahopdong], [Masv], [Maquanly], [Maphong], [Ngaylap], [Ngaybatdau], [Ngayketthuc]) VALUES (N'hd14', N'K1854807', N'ql01', N'k4105', CAST(N'2021-05-29' AS Date), CAST(N'2021-06-01' AS Date), CAST(N'2021-08-31' AS Date))
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'a1111', 111, N'a1 ', N'nam', 2, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'a1406', 406, N'a1 ', N'nữ', 6, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'a1407', 407, N'a1 ', N'nữ', 8, 0)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'a1409', 409, N'a1 ', N'nam', 6, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'a1410', 411, N'a2 ', N'nam', 0, 0)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'a1411', 411, N'a2 ', N'nam', 0, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'k2412', 412, N'k2 ', N'nữ', 2, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'k4105', 105, N'k4 ', N'nam', 5, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'k4505', 505, N'k4 ', N'nam', 3, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'k5101', 101, N'k5 ', N'nam', 8, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'k5202', 202, N'k5 ', N'nữ', 8, 1)
INSERT [dbo].[Phong] ([Maphong], [Sophong], [Khunha], [LoaiPhong], [SoluongSV], [TinhTrang]) VALUES (N'k5412', 412, N'k5 ', N'nữ', 0, 1)
INSERT [dbo].[QuanLy] ([Maquanly], [Hoten], [Ngaysinh], [Diachi], [SDT]) VALUES (N'ql01', N'Trần Văn Hiếu', CAST(N'1989-06-06' AS Date), N'123 Tích Lương', N'0345678937')
INSERT [dbo].[QuanLy] ([Maquanly], [Hoten], [Ngaysinh], [Diachi], [SDT]) VALUES (N'ql02', N'Nguyễn Hữu Thiết', CAST(N'1982-09-22' AS Date), N'175 Phú Xá', N'0928378474')
INSERT [dbo].[QuanLy] ([Maquanly], [Hoten], [Ngaysinh], [Diachi], [SDT]) VALUES (N'ql03', N'Hoàng Văn Biên', CAST(N'1980-06-09' AS Date), N'1111 Phú Xá', N'0998988855')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854801', N'Trần Thị', N'Duyên', CAST(N'2000-08-01' AS Date), N'nữ', N'091917991', N'0366217782', N'Điện Tử', N'54KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854802', N'Nguyễn Văn', N'Toàn', CAST(N'2000-10-25' AS Date), N'nam', N'091273773', N'0939488480', N'Điện', N'54TÐH')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854803', N'Trần Thị ', N'Nhi', CAST(N'2001-03-02' AS Date), N'nữ', N'019384893', N'0938483344', N'Điện tử', N'55DVT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854804', N'Phạm Yến', N'Linh', CAST(N'2000-12-16' AS Date), N'nữ', N'098237473', N'0982376433', N'Điện tử', N'54KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854805', N'Lưu Thị Tiểu', N'Nhị', CAST(N'2000-09-09' AS Date), N'nữ', N'023884744', N'0837654644', N'Điện tử', N'54KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854806', N'Lương Xuân', N'Trường', CAST(N'1999-03-02' AS Date), N'nam', N'092374448', N'0829734733', N'Cơ khí', N'53CÐT03')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854807', N'Nguyễn Văn', N'Toàn', CAST(N'1999-04-15' AS Date), N'nam', N'027374444', N'0293984833', N'Ô tô', N'53KTO02')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854808', N'Nguyễn Công', N'Phượng', CAST(N'2000-05-05' AS Date), N'nam', N'083764325', N'0566387788', N'Điện tử', N'54KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854809', N'Lò Thị', N'Thơm', CAST(N'2000-09-04' AS Date), N'nữ', N'019293843', N'0293949398', N'Kinh tế', N'54KT01')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854810', N'Nguyễn Phương', N'Trinh', CAST(N'2001-07-03' AS Date), N'nữ', N'029837343', N'0929748374', N'Kinh tế', N'54KT01')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854811', N'Phạm Ngọc', N'Trinh', CAST(N'2001-11-06' AS Date), N'nữ', N'029344739', N'0273733838', N'Kinh tế', N'54KT01')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1854812', N'Đào Yến', N'Anh', CAST(N'2000-03-02' AS Date), N'nữ', N'019384890', N'0938483342', N'Điện tử', N'54DVT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855801', N'Nguyễn Quang', N'Hải', CAST(N'2001-06-04' AS Date), N'nam', N'029384757', N'028377448', N'Cơ khí', N'55CM01')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855802', N'Nguyễn Văn', N'Toàn', CAST(N'1999-11-01' AS Date), N'nam', N'028474490', N'028378223', N'Cơ khí', N'53CÐT03')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855803', N'Quế Ngọc', N'Hải', CAST(N'1999-06-04' AS Date), N'nam', N'028474449', N'028378383', N'Cơ khí', N'53CÐT03')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855804', N'Nguyễn Thị', N'Thơm', CAST(N'2000-05-01' AS Date), N'nam', N'028474411', N'028378222', N'Cơ khí', N'54CÐT03')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855805', N'Đào Duy', N'Nhất', CAST(N'2001-05-01' AS Date), N'nam', N'028474415', N'028378226', N'Điện tử', N'55KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855806', N'Đào Duy', N'Nhất', CAST(N'1999-05-01' AS Date), N'nam', N'028474415', N'028378226', N'Điện tử', N'53KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855808', N'Lưu Thị Yến', N'Nhi', CAST(N'2002-06-29' AS Date), N'nữ', N'092773666', N'0926637822', N'Điện tử', N'56KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855809', N'Trần Đình', N'Trọng', CAST(N'1999-06-29' AS Date), N'nam', N'082637771', N'0927777338', N'Điện tử', N'53KMT')
INSERT [dbo].[SinhVien] ([Masv], [Hodem], [Ten], [Ngaysinh], [GioiTinh], [CMND], [SDT], [Khoa], [Lop]) VALUES (N'K1855810', N'Trần Thị Ánh', N'Tuyết', CAST(N'2001-03-13' AS Date), N'nữ', N'019384894', N'0938483342', N'Điện tử', N'55DVT')
ALTER TABLE [dbo].[HoaDonDienNuoc]  WITH CHECK ADD  CONSTRAINT [FK_HoaDonDienNuoc_Phong] FOREIGN KEY([Maphong])
REFERENCES [dbo].[Phong] ([Maphong])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] CHECK CONSTRAINT [FK_HoaDonDienNuoc_Phong]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc]  WITH CHECK ADD  CONSTRAINT [FK_HoaDonDienNuoc_QuanLy] FOREIGN KEY([Maquanly])
REFERENCES [dbo].[QuanLy] ([Maquanly])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] CHECK CONSTRAINT [FK_HoaDonDienNuoc_QuanLy]
GO
ALTER TABLE [dbo].[HoaDonPhong]  WITH CHECK ADD  CONSTRAINT [FK_HoaDonPhong_SinhVien] FOREIGN KEY([Masv])
REFERENCES [dbo].[SinhVien] ([Masv])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HoaDonPhong] CHECK CONSTRAINT [FK_HoaDonPhong_SinhVien]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [FK_HopDong_Phong] FOREIGN KEY([Maphong])
REFERENCES [dbo].[Phong] ([Maphong])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [FK_HopDong_Phong]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [FK_HopDong_QuanLy] FOREIGN KEY([Maquanly])
REFERENCES [dbo].[QuanLy] ([Maquanly])
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [FK_HopDong_QuanLy]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [FK_HopDong_SinhVien] FOREIGN KEY([Masv])
REFERENCES [dbo].[SinhVien] ([Masv])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [FK_HopDong_SinhVien]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc]  WITH CHECK ADD  CONSTRAINT [chk_HoaDonDienNuoc_hdDien] CHECK  (([CSCdien]>[CSDdien]))
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] CHECK CONSTRAINT [chk_HoaDonDienNuoc_hdDien]
GO
ALTER TABLE [dbo].[HoaDonDienNuoc]  WITH CHECK ADD  CONSTRAINT [chk_HoaDonDienNuoc_hdNuoc] CHECK  (([CSCnuoc]>[CSDnuoc]))
GO
ALTER TABLE [dbo].[HoaDonDienNuoc] CHECK CONSTRAINT [chk_HoaDonDienNuoc_hdNuoc]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [chk_HopDong_NgayBDvaKT] CHECK  (([Ngaybatdau]<[Ngayketthuc]))
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [chk_HopDong_NgayBDvaKT]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [chk_HopDong_Ngaylap] CHECK  (([Ngaylap]<[Ngaybatdau]))
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [chk_HopDong_Ngaylap]
GO
ALTER TABLE [dbo].[Phong]  WITH CHECK ADD  CONSTRAINT [chk_Phong_LoaiPhong] CHECK  (([LoaiPhong]=N'nữ' OR [LoaiPhong]='nam'))
GO
ALTER TABLE [dbo].[Phong] CHECK CONSTRAINT [chk_Phong_LoaiPhong]
GO
ALTER TABLE [dbo].[Phong]  WITH CHECK ADD  CONSTRAINT [chk_Phong_SoLuongSV] CHECK  (([SoluongSV]>=(0) AND [SoluongSV]<=(8)))
GO
ALTER TABLE [dbo].[Phong] CHECK CONSTRAINT [chk_Phong_SoLuongSV]
GO
ALTER TABLE [dbo].[SinhVien]  WITH CHECK ADD  CONSTRAINT [chk_SinhVien_Gioitinh] CHECK  (([GioiTinh]=N'nữ' OR [GioiTinh]='nam'))
GO
ALTER TABLE [dbo].[SinhVien] CHECK CONSTRAINT [chk_SinhVien_Gioitinh]
GO
/****** Object:  StoredProcedure [dbo].[cau8]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[cau8]
(
	@masv varchar(20)
)
AS
BEGIN
	IF(NOT EXISTS (SELECT * FROM SinhVien WHERE Masv = @masv))
			PRINT N'Sinh viên này không ở trong ký túc xá'
	ELSE
			PRINT N'Sinh viên này đang ở trong ký túc xá'
END
GO
/****** Object:  StoredProcedure [dbo].[cau9]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[cau9]
(
	@loaiphong nvarchar(10)
)
AS BEGIN
	--Nếu tồn tại phòng ít hơn 8 sv, tình trạng tốt, Loại phòng = loại phòng cần tìm hoặc = null(phòng đấy chưa có sv ở)
	IF (EXISTS (SELECT * FROM Phong WHERE SoluongSV<8 AND (LoaiPhong = @loaiphong OR LoaiPhong is NULL)  AND TinhTrang='True'))
		begin
			SELECT * FROM Phong WHERE SoluongSV<8 AND (LoaiPhong = @loaiphong OR LoaiPhong is NULL) AND TinhTrang='True'

		end
END
GO
/****** Object:  StoredProcedure [dbo].[pr_DienNuoc]    Script Date: 30/6/2021 10:33:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[pr_DienNuoc]
(
	@maphong varchar(10),
	@thang varchar(7)
)
AS
BEGIN
	IF(NOT EXISTS (SELECT * FROM HopDong WHERE Maphong = @maphong))
			PRINT N'Phòng không hợp lệ hoặc chưa có ai thuê!'
	ELSE
		begin
			if(NOT EXISTS (SELECT * FROM HoaDonDienNuoc WHERE Maphong = @maphong AND Thang=@thang))
				PRINT N'Phòng '+ @maphong+ N' chưa nộp tiền điện nước tháng '+@thang;
			else
				PRINT N'Phòng '+ @maphong+ N' đã nộp tiền điện nước tháng '+@thang;
		end
END

GO
