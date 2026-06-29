workspace "Microservices Architecture Course" "Учебная архитектура микросервисной системы" {

    model {
        user = person "Пользователь" "Клиент системы"

        softwareSystem = softwareSystem "Учебная микросервисная система" "Система для практики микросервисной архитектуры" {
            web = container "Web Application" "Пользовательский интерфейс" "React / TypeScript"
            apiGateway = container "API Gateway" "Единая входная точка для клиентских запросов" "Spring Cloud Gateway"
            orderService = container "Order Service" "Управляет заказами" "Java / Spring Boot"
            paymentService = container "Payment Service" "Обрабатывает платежи" "Java / Spring Boot"
            notificationService = container "Notification Service" "Отправляет уведомления" "Java / Spring Boot"
            orderDatabase = container "Order Database" "Хранит данные заказов" "PostgreSQL"
            messageBroker = container "Message Broker" "Асинхронный обмен событиями" "RabbitMQ"
        }

        user -> web "Работает с системой через браузер"
        web -> apiGateway "Вызывает API"
        apiGateway -> orderService "Передаёт запросы по заказам"
        orderService -> orderDatabase "Читает и пишет данные заказов"
        orderService -> paymentService "Запрашивает оплату"
        orderService -> messageBroker "Публикует событие OrderCreated"
        paymentService -> messageBroker "Публикует событие PaymentCompleted"
        notificationService -> messageBroker "Подписывается на события"
    }

    views {
        systemContext softwareSystem "SystemContext" {
            include *
            autoLayout
        }

        container softwareSystem "Containers" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }

            element "Software System" {
                background #1168bd
                color #ffffff
            }

            element "Container" {
                background #438dd5
                color #ffffff
            }

            element "Database" {
                shape cylinder
                background #438dd5
                color #ffffff
            }
        }

        theme default
    }
}
