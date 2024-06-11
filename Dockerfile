# Этап 1: Сборка зависимостей и установка необходимых инструментов
FROM golang:1.22.4 AS builder

# Устанавливаем необходимые утилиты
RUN apt-get update && apt-get install -y git

# Устанавливаем Gonkey
RUN go install github.com/lamoda/gonkey@latest

# Создаем рабочую директорию
WORKDIR /app

# Копируем модульные файлы и загружаем зависимости
COPY go.mod go.sum ./
RUN go mod tidy

# Копируем все файлы проекта
COPY . .

# Этап 2: Финальный образ для запуска тестов
FROM golang:1.22.4

# Копируем Gonkey и зависимости из этапа сборки
COPY --from=builder /go/bin/gonkey /go/bin/gonkey
COPY --from=builder /app /app

# Устанавливаем рабочую директорию
WORKDIR /app

# Команда по умолчанию для запуска тестов
CMD ["gonkey", "-tests=./gonkey/tests", "-host=https://api.nasa.gov/", "-v"]
