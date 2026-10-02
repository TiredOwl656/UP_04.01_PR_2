import '../models/brand.dart';
import '../models/customer.dart';
import '../models/loyalty_card.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/supplier.dart';

final seedCategories = <ProductCategory>[
  const ProductCategory(id: 1, name: 'Верхняя одежда', description: 'Куртки, пальто, пуховики'),
  const ProductCategory(id: 2, name: 'Футболки', description: 'Футболки, поло, лонгсливы'),
  const ProductCategory(id: 3, name: 'Джинсы', description: 'Джинсы, брюки, чинос'),
  const ProductCategory(id: 4, name: 'Платья', description: 'Платья, сарафаны, юбки'),
  const ProductCategory(id: 5, name: 'Обувь', description: 'Кроссовки, ботинки, кеды'),
];

final seedBrands = <Brand>[
  const Brand(id: 1, name: 'Nordwind', country: 'Германия', foundedYear: 1998),
  const Brand(id: 2, name: 'Siberia Wear', country: 'Россия', foundedYear: 2005),
  const Brand(id: 3, name: 'Urban Threads', country: 'США', foundedYear: 2011),
  const Brand(id: 4, name: 'Milano Moda', country: 'Италия', foundedYear: 1985),
  const Brand(id: 5, name: 'Tokyo Style', country: 'Япония', foundedYear: 2001),
  const Brand(id: 6, name: 'Alpine Gear', country: 'Австрия', foundedYear: 1993),
  const Brand(id: 7, name: 'Baltic Cotton', country: 'Латвия', foundedYear: 2014),
  const Brand(id: 8, name: 'Desert Line', country: 'ОАЭ', foundedYear: 2018),
];

final seedSuppliers = <Supplier>[
  const Supplier(id: 1, name: 'ООО «Северный текстиль»', country: 'Россия', email: 'sale@sevtext.ru', phone: '+79123456789'),
  const Supplier(id: 2, name: 'Euro Fashion GmbH', country: 'Германия', email: 'order@eurofashion.de', phone: '+79151234567'),
  const Supplier(id: 3, name: 'Milano Import SRL', country: 'Италия', email: 'info@milano-import.it', phone: '+79169876543'),
  const Supplier(id: 4, name: 'Asia Garment Co.', country: 'Китай', email: 'b2b@asiagarment.cn', phone: '+79135557788'),
];

final seedProducts = <Product>[
  Product(id: 1, name: 'Куртка зимняя Arctic', sku: 'NW-1001', brandId: 1, supplierId: 2, categoryIds: [1], size: 'L', color: 'Чёрный', price: 12990, stock: 12, year: 2023),
  Product(id: 2, name: 'Пальто шерстяное Classic', sku: 'NW-1002', brandId: 1, supplierId: 2, categoryIds: [1], size: 'M', color: 'Серый', price: 15990, stock: 5, year: 2022),
  Product(id: 3, name: 'Футболка хлопковая Basic', sku: 'SB-2001', brandId: 2, supplierId: 1, categoryIds: [2], size: 'S', color: 'Белый', price: 1290, stock: 40, year: 2023),
  Product(id: 4, name: 'Футболка с принтом Urban', sku: 'UT-2002', brandId: 3, supplierId: 4, categoryIds: [2], size: 'M', color: 'Синий', price: 1890, stock: 25, year: 2024),
  Product(id: 5, name: 'Джинсы Slim Fit', sku: 'UT-3001', brandId: 3, supplierId: 4, categoryIds: [3], size: '32', color: 'Индиго', price: 5490, stock: 18, year: 2023),
  Product(id: 6, name: 'Джинсы Relaxed', sku: 'BC-3002', brandId: 7, supplierId: 1, categoryIds: [3], size: '34', color: 'Голубой', price: 4990, stock: 0, year: 2022),
  Product(id: 7, name: 'Платье вечернее Milano', sku: 'MM-4001', brandId: 4, supplierId: 3, categoryIds: [4], size: 'S', color: 'Красный', price: 21990, stock: 3, year: 2023),
  Product(id: 8, name: 'Платье летнее Tokyo', sku: 'TS-4002', brandId: 5, supplierId: 4, categoryIds: [4], size: 'M', color: 'Цветочный', price: 8990, stock: 7, year: 2024),
  Product(id: 9, name: 'Кроссовки Alpine Trail', sku: 'AG-5001', brandId: 6, supplierId: 2, categoryIds: [5], size: '42', color: 'Зелёный', price: 9990, stock: 15, year: 2024),
  Product(id: 10, name: 'Ботинки Desert Pro', sku: 'DL-5002', brandId: 8, supplierId: 4, categoryIds: [5], size: '43', color: 'Песочный', price: 11990, stock: 9, year: 2023),
  Product(id: 11, name: 'Куртка демисезонная Wind', sku: 'NW-1003', brandId: 1, supplierId: 2, categoryIds: [1], size: 'XL', color: 'Синий', price: 10990, stock: 6, year: 2024),
  Product(id: 12, name: 'Худи оверсайз Street', sku: 'UT-2003', brandId: 3, supplierId: 4, categoryIds: [2], size: 'L', color: 'Чёрный', price: 3990, stock: 22, year: 2023),
  Product(id: 13, name: 'Рубашка классическая Office', sku: 'SB-2004', brandId: 2, supplierId: 1, categoryIds: [2], size: 'M', color: 'Голубой', price: 2990, stock: 30, year: 2022),
  Product(id: 14, name: 'Юбка миди Milano', sku: 'MM-4003', brandId: 4, supplierId: 3, categoryIds: [4], size: 'S', color: 'Чёрный', price: 6990, stock: 11, year: 2023),
  Product(id: 15, name: 'Брюки чинос Baltic', sku: 'BC-3003', brandId: 7, supplierId: 1, categoryIds: [3], size: '31', color: 'Бежевый', price: 4290, stock: 14, year: 2024),
  Product(id: 16, name: 'Кеды городские Tokyo', sku: 'TS-5003', brandId: 5, supplierId: 4, categoryIds: [5], size: '41', color: 'Белый', price: 7490, stock: 20, year: 2023),
  Product(id: 17, name: 'Пуховик Alpine Extreme', sku: 'AG-1004', brandId: 6, supplierId: 2, categoryIds: [1], size: 'L', color: 'Оранжевый', price: 24990, stock: 4, year: 2024),
  Product(id: 18, name: 'Свитшот Desert Soft', sku: 'DL-2005', brandId: 8, supplierId: 4, categoryIds: [2], size: 'M', color: 'Серый', price: 4590, stock: 17, year: 2022),
  Product(id: 19, name: 'Платье-сарафан Summer', sku: 'MM-4004', brandId: 4, supplierId: 3, categoryIds: [4], size: 'M', color: 'Жёлтый', price: 5990, stock: 8, year: 2024),
  Product(id: 20, name: 'Джинсы мом', sku: 'BC-3004', brandId: 7, supplierId: 1, categoryIds: [3], size: '30', color: 'Тёмно-синий', price: 5790, stock: 13, year: 2023),
  Product(id: 21, name: 'Куртка кожаная Biker', sku: 'UT-1005', brandId: 3, supplierId: 4, categoryIds: [1], size: 'M', color: 'Коричневый', price: 18990, stock: 2, year: 2022),
  Product(id: 22, name: 'Футболка поло Premium', sku: 'SB-2006', brandId: 2, supplierId: 1, categoryIds: [2], size: 'L', color: 'Зелёный', price: 2490, stock: 28, year: 2024),
];

final seedCustomers = <Customer>[
  Customer(
    id: 1,
    fullName: 'Иванов Иван Иванович',
    email: 'ivanov@example.com',
    phone: '+79161112233',
    card: LoyaltyCard(number: 'LC-000001', bonusPoints: 350, issuedAt: DateTime(2022, 3, 12)),
  ),
  Customer(
    id: 2,
    fullName: 'Петрова Анна Сергеевна',
    email: 'petrova@example.com',
    phone: '+79162223344',
    card: LoyaltyCard(number: 'LC-000002', bonusPoints: 120, issuedAt: DateTime(2023, 6, 1)),
  ),
  Customer(
    id: 3,
    fullName: 'Сидоров Пётр Алексеевич',
    email: 'sidorov@example.com',
    phone: '+79163334455',
  ),
];