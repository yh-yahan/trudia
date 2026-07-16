#include "CheckoutServiceTestHelper.h"

CheckoutServiceTestHelper::CheckoutServiceTestHelper()
{
    if (!m_dbManager.initialize(":memory:"))
    {
        qFatal("Failed to initialize in-memory database for tests");
    }

    // create repositories
    m_categoryRepo = std::make_unique<CategoryRepository>(m_dbManager.db());
    m_menuRepo = std::make_unique<MenuRepository>(m_dbManager.db());
    m_orderSessionRepo = std::make_unique<OrderSessionRepository>(m_dbManager.db());
    m_orderRepo = std::make_unique<OrderRepository>(m_dbManager.db());
    m_orderItemRepo = std::make_unique<OrderItemRepository>(m_dbManager.db());
    m_tableRepo = std::make_unique<TableRepository>(m_dbManager.db());
    m_taxSettingsRepo = std::make_unique<TaxSettingsRepository>(m_dbManager.db());
    m_membershipRepo = std::make_unique<MembershipRepository>(m_dbManager.db());
    m_membershipSettingsRepo = std::make_unique<MembershipSettingsRepository>(m_dbManager.db());
    m_membershipTransactionRepo = std::make_unique<MembershipTransactionRepository>(m_dbManager.db());
    m_restaurantRepo = std::make_unique<RestaurantRepository>(m_dbManager.db());
    m_receiptSnapshotRepo = std::make_unique<ReceiptSnapshotRepository>(m_dbManager.db());
    m_appStateRepo = std::make_unique<AppStateRepository>(m_dbManager.db());
    m_printerRepo = std::make_unique<PrinterRepository>(m_dbManager.db());
    m_regionalSettingsRepo = std::make_unique<RegionalSettingsRepository>(m_dbManager.db());
    m_userRepo = std::make_unique<UserRepository>(m_dbManager.db());
    m_kitchenSettingsRepo = std::make_unique<KitchenSettingsRepository>(m_dbManager.db());
    m_tableSettingsRepo = std::make_unique<TableSettingsRepository>(m_dbManager.db());
    m_reservationRepo = std::make_unique<ReservationRepository>(m_dbManager.db());

    // create services
    m_currencyService = std::make_unique<CurrencyService>();
    m_taxCalculationService = std::make_unique<TaxCalculationService>();
    m_authService = std::make_unique<AuthService>(*m_userRepo);

    m_membershipService = std::make_unique<MembershipService>(
        *m_membershipRepo, *m_membershipSettingsRepo, *m_membershipTransactionRepo);

    m_settingService = std::make_unique<SettingService>(
        *m_restaurantRepo, *m_printerRepo, *m_taxSettingsRepo,
        *m_membershipSettingsRepo, *m_kitchenSettingsRepo,
        *m_regionalSettingsRepo, *m_tableSettingsRepo, *m_currencyService);

    m_tableService = std::make_unique<TableService>(*m_tableRepo);

    m_reservationService = std::make_unique<ReservationService>(
        *m_reservationRepo, *m_tableService);

    m_receiptBuilder = std::make_unique<ReceiptBuilder>(*m_regionalSettingsRepo);
    m_windowsPrinterService = std::make_unique<WindowsPrinterService>();

    // create CheckoutService
    m_checkoutService = std::make_unique<CheckoutService>(
        *m_orderSessionRepo,
        *m_orderRepo,
        *m_orderItemRepo,
        *m_restaurantRepo,
        *m_printerRepo,
        *m_tableRepo,
        *m_membershipRepo,
        *m_membershipTransactionRepo,
        *m_taxSettingsRepo,
        *m_appStateRepo,
        *m_receiptSnapshotRepo,
        *m_regionalSettingsRepo,
        *m_receiptBuilder,
        *m_windowsPrinterService,
        *m_taxCalculationService,
        *m_membershipService,
        *m_settingService,
        *m_tableService,
        *m_reservationService,
        *m_authService,
        m_dbManager
    );
}

int CheckoutServiceTestHelper::createCategory(const QString &name)
{
    Category category;
    category.category = name;

    m_categoryRepo->create(category);

    auto categories = m_categoryRepo->getAllCategories();

    return categories.back().id;
}

int CheckoutServiceTestHelper::createMenuItem(const QString &name,
                                              qint64 price,
                                              bool isTaxable)
{
    if (m_defaultCategoryId == 0)
        m_defaultCategoryId = createCategory();

    Menu menu;
    menu.item = name;
    menu.category_id = m_defaultCategoryId;
    menu.price = price;
    menu.is_available = true;
    menu.is_taxable = isTaxable;

    m_menuRepo->create(menu);

    auto menuItems = m_menuRepo->getAllMenuItems();

    return menuItems.back().id;
}

int CheckoutServiceTestHelper::createTestSession(int displayNumber, 
                                                 const QString& orderType,
                                                 qint64 discount)
{
    OrderSession session;
    session.display_number = displayNumber;
    session.order_type = orderType;
    session.status = "open";
    session.discount = discount;
    session.subtotal = 0;
    session.tax = 0;
    session.total = 0;

    m_orderSessionRepo->create(session);
    return session.id;
}

int CheckoutServiceTestHelper::createOrderForSession(int sessionId, int displayNumber)
{
    Order order;
    order.order_session_id = sessionId;
    order.display_number = displayNumber;
    order.status = "open";

    m_orderRepo->create(order);
    return order.id;
}

void CheckoutServiceTestHelper::addOrderItem(int orderId, int menuId, int quantity)
{
    auto menu = m_menuRepo->getMenuItemById(menuId);
    Q_ASSERT(menu.has_value());

    OrderItem item;
    item.order_id = orderId;
    item.item_id = menu->id;
    item.item_name = menu->item;
    item.price = menu->price;
    item.quantity = quantity;
    item.is_taxable = menu->is_taxable;

    m_orderItemRepo->create(item);
}

void CheckoutServiceTestHelper::setTaxSettings(bool enabled, qint64 rate)
{
    TaxSettings settings;
    settings.enabled = enabled;
    settings.rate = rate;

    m_taxSettingsRepo->save(settings);
}

int CheckoutServiceTestHelper::createSessionWithItems(int displayNumber,
                                                      qint64 discount,
                                                      const QList<QVariantMap>& items)
{
    int sessionId = createTestSession(displayNumber, "dine_in", discount);

    int orderId = createOrderForSession(sessionId);

    for (const auto& itemData : items)
    {
        int menuId = createMenuItem(
            itemData["name"].toString(),
            itemData["price"].toInt(),
            itemData["taxable"].toBool());

        addOrderItem(orderId,
                     menuId,
                     itemData["quantity"].toInt());
    }

    return sessionId;
}

CheckoutServiceTestHelper::~CheckoutServiceTestHelper() = default;
