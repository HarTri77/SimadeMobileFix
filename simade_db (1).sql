-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 14, 2025 at 01:42 PM
-- Server version: 8.0.30
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `simade_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `aduan`
--

CREATE TABLE `aduan` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `judul` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `isi_aduan` text COLLATE utf8mb4_general_ci NOT NULL,
  `kategori` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` enum('baru','diproses','selesai') COLLATE utf8mb4_general_ci DEFAULT 'baru',
  `tanggapan` text COLLATE utf8mb4_general_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `berita`
--

CREATE TABLE `berita` (
  `id` int NOT NULL,
  `judul` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `konten` text COLLATE utf8mb4_general_ci NOT NULL,
  `gambar` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `penulis_id` int NOT NULL,
  `views` int DEFAULT '0',
  `published_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `judul` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `pesan` text COLLATE utf8mb4_general_ci NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `expired_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `token`, `expired_at`, `created_at`) VALUES
(1, 1, 'd50162c736d093744ba76307a8ea6ab784f717da85cff97cd24be0c0fd93a856b257259c0902e5436bbb69eec1e4e62f8106dab34958155c9bd4df608bf6b886', '2025-12-10 14:42:53', '2025-11-10 07:42:53'),
(2, 1, 'def41998b80b392aedc7704367927d4da0c85fc1a5a0858cad11fcb99bf68957d8b5a91d8f17420bf39816e0cbc4d08cab6b6d9e0e5a2ab1decdbc5da95ae947', '2025-12-10 14:43:01', '2025-11-10 07:43:01'),
(3, 1, '149dbb7b703147dfd10dd35e4bda5b1dcf76c8243870417e44e73a511377a2f430b0b14b9dba816e2a3b63eb05e90a145c894dde3c51d1b08ef04b9124291229', '2025-12-10 14:43:08', '2025-11-10 07:43:08'),
(4, 1, 'fe4c71f873ed8cea9f1d0b7e01dffafa2e12b89ac358a3a1cff928071a801d66034e1010e4e7f7df47aecf25ea3b7e86bf59fe0d12f7ee8ecad02c92bed46be7', '2025-12-10 15:20:01', '2025-11-10 08:20:01'),
(5, 1, '28c81e72e49482a3b0ad21e53ad7f2cbf877786e07cf186b72c8c9e2b924002ec08d6d27d69b5ec1113bd7769d49ca0ac376cd58d7b876ab9021d116cc0f5aed', '2025-12-10 15:25:02', '2025-11-10 08:25:02'),
(6, 1, '1c40bec05fd3683c507e05e09c6f8868342cadf5320cd5e7faed7188c651f80e4080041cbc14708e9f8a02d060d55ef97fcdb590d1d6f7deac5e8c818e583617', '2025-12-11 12:58:12', '2025-11-11 05:58:12'),
(7, 1, '1c405c21876ac62393b374390f070fe6cda5f97d57c5e1872a41f5c24a5a0e56592a6cca266a474373fa3cfbeb34853e1dd707a631705663c3b5c70e994aeb75', '2025-12-11 12:59:38', '2025-11-11 05:59:38'),
(8, 1, '3c8127c0943b6cebb1a13c64fa2d9427545b87a04194c680ba580c64a9cbe30e9fbb57e84695e81c3e7ed3cd8fce6f45fff98bc105077606796ec248669d8697', '2025-12-11 12:59:42', '2025-11-11 05:59:42'),
(9, 1, '27198a58af0a7d75f1f09bccf6b44d19f747504c3ec91f827491f125ce554c1453ddc214a8739a4fbc5ea6b249571b2ade8001853f71dee68dc43047fb211481', '2025-12-11 12:59:51', '2025-11-11 05:59:51'),
(10, 1, 'dd786a14031095847c86ebe1c3e3a8675087ae48aa51a57236dc479062364dea25b4f899d8c88e9406ebca89ea2ecc8c58a60072d71d76aa61cb974b040add5e', '2025-12-11 13:05:12', '2025-11-11 06:05:12'),
(11, 2, '6c0e811e997a55b372c926bbbdb4c08676c5f74094a6eafb3e6073470552e20690ef915ef267e94f014eef3b3bb63749ce3d06317c610c4e81d1bedebab02580', '2025-12-11 13:05:41', '2025-11-11 06:05:41'),
(12, 2, '750c391f63a5003b96517e58fefcffe502e05e94de6844edda11d66f1a847d7428835e758496250de1d678c0d0150a8d23ab004451a2c318a02a9c7bf064cd9c', '2025-12-11 13:05:44', '2025-11-11 06:05:44'),
(13, 2, 'd646b7e3ac3c35bb7a5ebbffb51eee75e2f974a09313013d0eb3de6240166eaeb8456125f80a525b2112070c7fe64be1ed150c9bf4b8d37e47add8ea199cf209', '2025-12-11 13:09:18', '2025-11-11 06:09:18'),
(14, 1, '14dc8adb40f5d94f7febc30fced57255aa6d91725ad4d6c9555b364bf4ab5f5685b17c22545809b4a70cbdd1324ca7081357d32cc655794d2c619243afd6f0a7', '2025-12-11 13:10:00', '2025-11-11 06:10:00'),
(15, 2, '17bcdbd42f318c9892982ffc75c355eaf602f241197653e1f40939ff68b545850134ae1cfe220f306b29f84ee067bbac9e65b053669a7aaa3b4067dda1397116', '2025-12-11 13:21:24', '2025-11-11 06:21:24'),
(16, 2, 'c2e20faa37426a6e3c2339393ddf5f10b86c7c381928fc73991d56ee4d32a4a6a90a6c10762ba239afb6321eba49e21134b1486b3d8abe2d68af37102fe17d23', '2025-12-11 13:24:27', '2025-11-11 06:24:27'),
(17, 2, '98b34bd6402574880f9fb2e9a8fe33ef213b4fe4dc2706a57eb3e95c0d8df5dd924d4215e71072286bf96343a172f889c42af8a2f7d4797db4cd373f80a96698', '2025-12-11 13:32:22', '2025-11-11 06:32:22'),
(18, 2, '03b07170255f7dfa5c9e2669f88ff47857e2aca6a24b280934b084796f95326cd0671e937a4148a720f991f98d39d4600475872feb2d58f6a41bca9086e31cff', '2025-12-11 13:37:49', '2025-11-11 06:37:49'),
(19, 1, 'f85c8e7e7cf0baa3e5023071501db44859a944ae46eed9fb28b5fb400a4db147f10af4875b70e9cb1093a4661ef44a312883e0a0104db4b03f48be29e73b743a', '2025-12-11 13:39:19', '2025-11-11 06:39:19'),
(20, 2, '75f8bfb8091ae208857fddd1e94c507fbc262db1875ac14aff6d50ad4de3808b9c554da17c01673317fe24ede090597c11d490c5f5c71addc7dfc7bdeba45c74', '2025-12-11 14:09:43', '2025-11-11 07:09:43'),
(21, 1, '0f733d31195a9b05c9338f5c788b13983ec6bd9bd3afaea4bc51bd3bdc34bb1d000dd6c9a426577feb10828a33d97274b823cb806e79621b14d0624d03b6e626', '2025-12-12 08:09:32', '2025-11-12 01:09:32'),
(22, 2, '465ff0c1f3a3198587f6e3f7567d88c9b1dbe89105d48111a566faee6dc2f5511f24bef9d13052b7039c2ab62682d5b4b6ccfad164195ecb184f7689d425b9c4', '2025-12-12 08:10:27', '2025-11-12 01:10:27'),
(23, 1, 'df78caae3fab8ed24a0c36863c92a0ce9d6acc5d0dca7f2aea654d9e90d6bb75a29cf06d743551f0a5f80794faa56978b37a48ea40dcdd5c9111e6fad7e572a5', '2025-12-12 08:15:00', '2025-11-12 01:15:00'),
(24, 1, '65e07ce517c2e73e7072243cfa1c96753af4a8767b9c53d823ade85a479fc462b348b9900c28d27b4cd5b77dce6c21beba789789079e359af57136b54a9f8916', '2025-12-12 08:27:08', '2025-11-12 01:27:08'),
(25, 1, 'ec6b0a2aabb0138e94fae580022051e7b28f2fc9a51e46b35e227ca33de423179a13d3bfb94c67c0bf5104047088afa96d800c7118306204d585c34210a605fb', '2025-12-12 08:33:57', '2025-11-12 01:33:57'),
(26, 1, '0fe68f4174c1cbdb41967b274ddc3b75ad923a5b4eb58591335ab594b6669151e2e594dd895fe51f3d934110edc9fdcd9b1aec00cf67d4da6c68becc1b2e5b82', '2025-12-12 08:37:38', '2025-11-12 01:37:38'),
(27, 1, 'f739b7fb2eb0719e834b68f0df82c840f65a916b25ff88ceb8d05dc0643afe8184825d42936f5ab77ca7a76c0b580fd47b0abd521066e97994e672cfb2b93791', '2025-12-12 08:39:00', '2025-11-12 01:39:00'),
(28, 1, '0984ccc2d10df2fbfa02adfc24e2483fad5e350485f12716d9439f5fe5f76a3ab303cd7dd598b77408e809660a4bab70a6e7c048b17b87779a721c2958885803', '2025-12-12 11:03:48', '2025-11-12 04:03:48'),
(29, 1, 'd45b3d327e0f3cdba9b2204bff0e3411a6ce3ba20cc65257b093ba315d435fb179e76c1fc3c7a7a52cf45de951726f792ebcb6bd909ba3ea67a80d226a36214a', '2025-12-12 11:24:11', '2025-11-12 04:24:11'),
(30, 1, '33254c07a4db5bcf612d892499976fa4c98a56e1e0c6eed992cb5f65a152ac50d85ab445f3c1b25daa31c4971f27990b3fd33e714defdbc45bb83b8aad432e33', '2025-12-12 11:45:31', '2025-11-12 04:45:31'),
(31, 2, 'b2aead51968f8c88394f46f6acc2d0600cfa6e9e9d750895f5a31c2e59baa44012d4459d8a7e744f925de236859b9234e34f3549e7140c2ecff5499c3924213d', '2025-12-12 11:46:28', '2025-11-12 04:46:28'),
(32, 2, '895336bbfd6a0306f98d082d132910f2303780031297257f8243cf3a1f13850ec1c9a63f202b70403e26fae5e7923363a91770fdd009a0d4afe42ac5e1816b0d', '2025-12-12 11:47:02', '2025-11-12 04:47:02'),
(33, 1, 'a7e35153774247d5930966f37afb5839ab436047cf1d38a862f44b448ba94d29f7e8391db1d0aeb8bcf349946442c2bb3ba53e208f3cd43432cc4be1f5597a41', '2025-12-13 08:51:55', '2025-11-13 01:51:55'),
(34, 1, '8b1844d56289da41f5078b940f8bb65276db21f07dbbdcb729bc693aed20942e3cef37399a7a7e1ce0c7eb7ae3fd787744a57ab567414706dbe7af81f6c8ff7c', '2025-12-13 09:20:56', '2025-11-13 02:20:56'),
(35, 2, '0c61c108ac5687904547ba4f3606ce477a03839ef5e60cce3385b3152403d0428c95f208a711abe17b90dc77908b4938234690f90547e785e09b7498efaaa9c9', '2025-12-13 09:23:25', '2025-11-13 02:23:25'),
(36, 1, '4efd32b0cc69dc7ec358a026d1521abff51588d81135eb9a0cd735e8c6ec837a046f788a12e54537975c95f591cbf4f7c807ca1a4b38dc5be86333093b6143c0', '2025-12-13 12:37:26', '2025-11-13 05:37:26'),
(37, 1, 'c159a34fc1e565e9de50fb9617afb3860d053bcc8b67bbeeec4dc5b12ce35796c605e53695c768a064075d73f3404552262ae15bdc98b8c09b34b68aabeb7b9f', '2025-12-13 12:48:26', '2025-11-13 05:48:26'),
(38, 1, 'f64b74349a011fc5ff57b3f0087bab7eb38126276df8ff051879d3acf84479eb26a8aa39a2256d347118c8845dc216efff256de8b3ba0ad343b1ba7192214849', '2025-12-14 09:35:35', '2025-11-14 02:35:35'),
(39, 1, '273d9c211b8f1b79597ce0c87f924918202719eae29d6bd674bced3ae5afbdde805b92e883568a81ffec1961ce515dd38c273bff9b1eaedebf9b53df514652fc', '2025-12-14 09:37:14', '2025-11-14 02:37:14'),
(40, 2, '147e00a8bd7e6f7300920288db97993d6e61755587771bb1224470beb29a908aa776fd876aa2b5f8568fcca1d713f1a61cac1000b5ff0fad1a9bcb177d7abf24', '2025-12-14 09:40:21', '2025-11-14 02:40:21'),
(41, 2, '320fba03601b4f39f568706ff91e4681c3059bd7977b3288326c7e64860187ac6a721f78bb07d762bc467d5d9e129d4166c3296b4cd6552a5c16511490649f6a', '2025-12-14 09:59:09', '2025-11-14 02:59:09'),
(42, 2, '84a0f3f7a9f8e958eb4e22a2dfa74a59af93c310454a3f8dfa8d64a4b3a0cdec8b5fc25f1cb07d30b4e4e1bec46eaa99ea28311be5864ae62fec26c528a4e601', '2025-12-14 10:09:27', '2025-11-14 03:09:27'),
(43, 1, '64cdee886e9787dc3ab8d45e20cdbba540cc6c3f71329004fa936239c511c75796b09a37c63e67ad060e0e35bc33897197d1a26d41507b6a0095eb2d137bcc7c', '2025-12-14 10:10:18', '2025-11-14 03:10:18'),
(44, 2, 'ed9f20627ed7c90d51a81c3470a4e8ef7a9e5f35dd01d0af09cccf3cd6f0b3430800c01db380ffb6cf515994f6d23f6e9a55d8f401bb02065cc2f85309860c1c', '2025-12-14 10:13:36', '2025-11-14 03:13:36'),
(45, 2, 'd451d6361a7ebd8ce956939a06279795f2ed91e5a3a393c03e6d0a6c5fc0967d930272f793555fd1242f4f184a8875158bfda86eb6b0857044a6f3e11bb0f107', '2025-12-14 10:37:26', '2025-11-14 03:37:26'),
(46, 2, 'cc5a75b88ba50e31dd70bc896eca0bcbdd17dc458478b4b1d04800c6b9a57c2e7739b8c9e35f192c3a477bf8e22b2d870a2e4a29d158318c0fe8a4bbf550007b', '2025-12-14 10:39:56', '2025-11-14 03:39:56'),
(47, 2, 'b17bb3496fa30517fe53ba83cc2ec9efc0ef896116887ab91e8dd2b155fe539bab4170e4de32be0609d2baafd233f713b445572625cb6b1dd35aba76f60b7df3', '2025-12-14 10:49:00', '2025-11-14 03:49:00'),
(48, 1, '40d0b3cf86d04e13aeafad9b5b19a39e7db15e64ceefbed9e99457c30d00a8e0f511d3f75c6a30def4e4b8b43f6e8333155855faf6f9bcad23fb793864f7e87c', '2025-12-14 17:36:17', '2025-11-14 10:36:17'),
(49, 2, '4cdce835adeddfea8d7523f2df0baa44289cf2e70f98a19c544f7861ecd4ed550bf8a5372c4b9e24d0ebaf791a91959610c4d66ae1d27f8e2f2f3d60e4d8839c', '2025-12-14 17:36:46', '2025-11-14 10:36:46'),
(50, 2, '42e44167fe4f85283cd4c248ed0793ce5d44537ed55b60257e5e7925f43d27cd352a23e0631c5ac47461a3649b500512cb9828c73f881686791a088e8b6e01a9', '2025-12-14 17:48:49', '2025-11-14 10:48:49'),
(51, 1, 'e4f44e1e9bbc5fb6e057bd1265dfee2ec949c95847c49c76b1470797e35a9754cc82ae6bf38c9226170d12bfc21aab1212f87d981d29e2dd1d966f0fb6a5df96', '2025-12-14 17:50:28', '2025-11-14 10:50:28'),
(52, 2, '4f768a8d53aaa8b88f5f6c7f38c6985d8fcd24a15ffaa998051bbdffa56cd1837d351385b5980204325d684eb1addeef4c8193057ef2fdaa3b7bdbafff913859', '2025-12-14 18:05:44', '2025-11-14 11:05:44'),
(53, 1, 'e4bc6d72cc013f39d5df5d14971f3b144680638df240091346a425b4192893a867c00e39895bd4b3b089044d0cdf40194bfa08c7f66d105e3acf35d258f9c3bc', '2025-12-14 18:06:39', '2025-11-14 11:06:39'),
(54, 2, '525ffab8be729a043737c437e5c54867906df91a88916fba713fe0016ddae87f642f839547d2a8b4c84e54b0d9e9716b5112b7b1115ae16cd142e6f15dddbe3f', '2025-12-14 18:07:18', '2025-11-14 11:07:18'),
(55, 1, 'c00acd8ae12c158a2a8fd0ab02476074ef956b71db6b7a11b733460f9af6e5043ef3bb570d388eb659d6531823fd752ede597b0df02b1aa65edd38db92c62184', '2025-12-14 18:07:59', '2025-11-14 11:07:59');

-- --------------------------------------------------------

--
-- Table structure for table `surat`
--

CREATE TABLE `surat` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `jenis_surat` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keperluan` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_pendukung` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','diproses','selesai','ditolak') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `catatan_admin` text COLLATE utf8mb4_unicode_ci,
  `file_hasil` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tanggal_pengajuan` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tanggal_diproses` datetime DEFAULT NULL,
  `tanggal_selesai` datetime DEFAULT NULL,
  `diproses_oleh` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `no_hp` varchar(15) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `alamat` text COLLATE utf8mb4_general_ci,
  `role` enum('warga','admin') COLLATE utf8mb4_general_ci DEFAULT 'warga',
  `foto_profile` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8mb4_general_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `no_hp`, `alamat`, `role`, `foto_profile`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Tri', 'Tri@gmail.com', '$2y$10$0sFu4yHug6gaSDoE/FOvfu119ExfuaZQkiHkcmR/x4Ffph4P8yURy', '123456789123', 'arahan sukasari', 'warga', NULL, 'active', '2025-11-10 07:42:31', '2025-11-10 07:42:31'),
(2, 'Admin SIMADE', 'admin@simade.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567890', 'Kantor Desa', 'admin', NULL, 'active', '2025-11-11 06:03:15', '2025-11-11 06:03:15');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `aduan`
--
ALTER TABLE `aduan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `berita`
--
ALTER TABLE `berita`
  ADD PRIMARY KEY (`id`),
  ADD KEY `penulis_id` (`penulis_id`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `surat`
--
ALTER TABLE `surat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `diproses_oleh` (`diproses_oleh`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aduan`
--
ALTER TABLE `aduan`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `berita`
--
ALTER TABLE `berita`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `surat`
--
ALTER TABLE `surat`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `aduan`
--
ALTER TABLE `aduan`
  ADD CONSTRAINT `aduan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `berita`
--
ALTER TABLE `berita`
  ADD CONSTRAINT `berita_ibfk_1` FOREIGN KEY (`penulis_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `surat`
--
ALTER TABLE `surat`
  ADD CONSTRAINT `surat_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `surat_ibfk_2` FOREIGN KEY (`diproses_oleh`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
