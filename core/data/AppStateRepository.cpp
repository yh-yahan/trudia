#include "AppStateRepository.h"

#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QDebug>

AppStateRepository::AppStateRepository(QSqlDatabase db): m_db(db) {}

std::optional<QString> AppStateRepository::get(const QString &key) const
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT value
        FROM app_state
        WHERE key = :key
    )");
    
    query.bindValue(":key", key);

    if (!query.exec())
    {
        qWarning() << "Failed to get app state:" << query.lastError();
        return std::nullopt;
    }

    if (!query.next())
        return std::nullopt;

    return query.value("value").toString();
}

bool AppStateRepository::set(const AppState &appState)
{
    QSqlQuery query(m_db);

    query.prepare(R"(
        INSERT INTO app_state (key, value)
        VALUES (:key, :value)
        ON CONFLICT(key) DO UPDATE SET
            value = excluded.value,
            updated_at = CURRENT_TIMESTAMP
    )");

    query.bindValue(":key", appState.key);
    query.bindValue(":value", appState.value);

    if (!query.exec())
    {
        qWarning() << "Failed to save app state:" << query.lastError();
        return false;
    }

    return true;
}

bool AppStateRepository::exists(const QString &key) const
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        SELECT 1
        FROM app_state
        WHERE key = :key
        LIMIT 1
    )");

    query.bindValue(":key", key);

    if (!query.exec())
    {
        qWarning() << "Failed to check app state existence:" << query.lastError();
        return false;
    }

    return query.next();
}

bool AppStateRepository::remove(const QString &key)
{
    QSqlQuery query(m_db);
    query.prepare(R"(
        DELETE FROM app_state
        WHERE key = :key
    )");

    query.bindValue(":key", key);

    if (!query.exec())
    {
        qWarning() << "Failed to delete app state:" << query.lastError();
        return false;
    }

    return true;
}
