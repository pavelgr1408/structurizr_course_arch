workspace "Food Ordering Platform" "Контейнерная диаграмма C4 для платформы оформления заказов еды." {

    model {
        customer = person "Customer" "Клиент, который использует фронтальные приложения для просмотра меню, оформления заказа и оплаты."

        paymentGateway = softwareSystem "Payment Gateway" "Внешняя платёжная система для проведения оплаты." {
            tags "External System"
        }

        warehouseAccountingSystem = softwareSystem "Warehouse Accounting System" "Внешняя система складского учёта для получения данных об остатках ингредиентов." {
            tags "External System"
        }

        roboticConveyor = softwareSystem "Robotic Conveyor" "Роботизированная линия приготовления блюд." {
            tags "External System"
        }

        foodOrderingPlatform = softwareSystem "Food Ordering Platform" "Система для просмотра меню, оформления заказов, авторизации клиентов, проведения оплаты и управления роботизированным приготовлением блюд." {

            iosApp = container "iOS App" "Мобильное приложение для клиентов на iOS." "Swift"
            androidApp = container "Android App" "Мобильное приложение для клиентов на Android." "Kotlin"
            webApp = container "Web App" "Веб-приложение для клиентов." "TypeScript / React"
            webTerminal = container "Web Terminal" "Веб-терминал для операторов или сотрудников." "TypeScript / React"

            apiGateway = container "API Gateway" "Единая точка входа для всех фронтальных приложений. Выполняет маршрутизацию запросов и обращается к сервису авторизации для проверки токенов." "Nginx"

            orderService = container "Order Service" "Сервис управления корзиной и заказами. Оформляет заказы, бронирует ингредиенты, передаёт данные для оплаты и отправляет заказы на приготовление." "Java"
            orderDatabase = container "Order Database" "Хранит корзины и заказы." "PostgreSQL" {
                tags "Database"
            }

            menuService = container "Menu Service" "Сервис управления меню. Предоставляет позиции меню и может исключать позиции, если недостаточно ингредиентов." "Java"
            menuDatabase = container "Menu Database" "Хранит список меню, состав позиций меню и данные для отображения доступности." "PostgreSQL" {
                tags "Database"
            }

            ingredientService = container "Ingredient Service" "Сервис управления ингредиентами. Является мастер-сервисом по данным об ингредиентах и их доступности." "Java"
            ingredientDatabase = container "Ingredient Database" "Хранит ингредиенты, остатки и данные о бронировании ингредиентов под заказы." "PostgreSQL" {
                tags "Database"
            }

            authService = container "Auth Service" "Сервис авторизации клиентов. Выполняет авторизацию, выдачу токенов и проверку актуальности токенов." "Java"
            authDatabase = container "Auth Database" "Хранит пользователей и данные, необходимые для авторизации." "PostgreSQL" {
                tags "Database"
            }

            authTokenCache = container "Auth Token Cache" "Хранит актуальные авторизационные токены для быстрой проверки каждого запроса." "Redis" {
                tags "Database"
            }

            paymentService = container "Payment Service" "Сервис проведения оплаты. Проверяет данные оплаты по собственному хранилищу и инициирует платёж во внешнем платёжном шлюзе." "Java"
            paymentDatabase = container "Payment Database" "Хранит идентификатор заказа, идентификатор клиента, сумму к оплате и статус оплаты для валидации платёжного запроса." "PostgreSQL" {
                tags "Database"
            }

            robotService = container "Robot Service" "Сервис управления приготовлением блюд. Передаёт задания на роботизированный конвейер и получает результат готовности блюда." "Java"
            robotDatabase = container "Robot Database" "Хранит ключи и статусы отправленных запросов на приготовление блюд." "PostgreSQL" {
                tags "Database"
            }
        }

        customer -> iosApp "Отправляет запросы"
        customer -> androidApp "Отправляет запросы"
        customer -> webApp "Отправляет запросы"
        customer -> webTerminal "Отправляет запросы"

        iosApp -> apiGateway "Выполняет запросы к API" "REST"
        androidApp -> apiGateway "Выполняет запросы к API" "REST"
        webApp -> apiGateway "Выполняет запросы к API" "REST"
        webTerminal -> apiGateway "Выполняет запросы к API" "REST"

        apiGateway -> authService "Авторизовать клиента, получить авторизационный токен и провалидировать токен" "REST"
        apiGateway -> orderService "Оформить заказ" "REST"
        apiGateway -> menuService "Получить меню" "REST"
        apiGateway -> paymentService "Провести оплату заказа" "REST"

        authService -> authDatabase "Читает и записывает пользователей" "JDBC"
        authService -> authTokenCache "Сохраняет и проверяет актуальные авторизационные токены" "Redis protocol"

        orderService -> orderDatabase "Читает и записывает корзины и заказы" "JDBC"
        orderService -> ingredientService "Забронировать ингредиенты для заказа" "HTTP REST"

        menuService -> menuDatabase "Читает позиции меню, состав позиций и данные доступности" "JDBC"

        ingredientService -> ingredientDatabase "Читает и записывает ингредиенты, остатки и бронирования" "JDBC"
        ingredientService -> warehouseAccountingSystem "Получить данные складского учёта по ингредиентам" "HTTP REST"

        ingredientService -> menuService "Передать данные об ингредиентах и их доступности" "Kafka" {
            tags "Asynchronous"
        }

        orderService -> paymentService "Передать идентификатор заказа, идентификатор клиента и сумму для оплаты" "Kafka" {
            tags "Asynchronous"
        }

        paymentService -> paymentDatabase "Читает и записывает данные для валидации оплаты, сумму к оплате и статус оплаты" "JDBC"
        paymentService -> paymentGateway "Провести оплату" "HTTPS / REST"

        paymentService -> orderService "Передать результат проведения оплаты" "Kafka" {
            tags "Asynchronous"
        }

        orderService -> robotService "Передать заказ на приготовление блюда" "Kafka" {
            tags "Asynchronous"
        }

        robotService -> robotDatabase "Читает и записывает ключи и статусы запросов на приготовление" "JDBC"

        robotService -> roboticConveyor "Передать задание на приготовление блюда" "Kafka" {
            tags "Asynchronous"
        }

        roboticConveyor -> robotService "Передать результат готовности блюда" "Kafka" {
            tags "Asynchronous"
        }

        robotService -> orderService "Передать результат готовности блюда" "Kafka" {
            tags "Asynchronous"
        }
    }

    views {
        container foodOrderingPlatform "Container_Diagram" "Booking" {
            include *
            autolayout lr
        }

        styles {
            element "Person" {
                shape Person
                background "#08427B"
                color "#FFFFFF"
            }

            element "Software System" {
                background "#1168BD"
                color "#FFFFFF"
            }

            element "External System" {
                background "#999999"
                color "#FFFFFF"
            }

            element "Container" {
                background "#438DD5"
                color "#FFFFFF"
            }

            element "Database" {
                shape Cylinder
                background "#438DD5"
                color "#FFFFFF"
            }

            relationship "Asynchronous" {
                dashed true
                color "#707070"
            }
        }
    }
}
