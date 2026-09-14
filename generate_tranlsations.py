import os
import re
import json
from pathlib import Path
from deep_translator import GoogleTranslator

# Регулярное выражение для поиска строк вида 'some_key'.tr() или "some_key".tr()
TR_REGEX = re.compile(r"['\"]([a-zA-Z0-9_\-\.]+)['\"]\s*\.\s*tr\(\)")

def extract_keys_from_dir(directory: Path) -> set:
    keys = set()
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                file_path = Path(root) / file
                try:
                    content = file_path.read_text(encoding="utf-8")
                    found = TR_REGEX.findall(content)
                    keys.update(found)
                except Exception as e:
                    print(f"Ошибка при чтении файла {file_path}: {e}")
    return keys

def load_existing_json(file_path: Path) -> dict:
    if file_path.exists():
        try:
            return json.loads(file_path.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}

def save_json(file_path: Path, data: dict):
    # Сортируем ключи для красоты и удобочитаемости
    sorted_data = {k: data[k] for k in sorted(data.keys())}
    file_path.write_text(json.dumps(sorted_data, ensure_ascii=False, indent=2), encoding="utf-8")

def main():
    # ПУТИ К ВАШИМ ПАПКАМ (настройте под себя, если нужно)
    SRC_DIR = Path("lib")          # Где лежит ваш код Flutter
    LOCALES_DIR = Path("assets/translations") # Куда easy_localization сохраняет json-файлы

    print("🔍 Сканирую проект на наличие .tr() ключей...")
    keys = extract_keys_from_dir(SRC_DIR)
    print(f"Найдено уникальных ключей: {len(keys)}")


    # Создаем папку для локалей, если её нет
    LOCALES_DIR.mkdir(parents=True, exist_ok=True)

    # Настройки языков (исходя из структуры: en.json, ru.json)
    languages = {
        "en": "en",
        "ru": "ru"
    }

    translator = GoogleTranslator(source='auto', target='en')

    for lang_code, target_lang in languages.items():
        json_file = LOCALES_DIR / f"{lang_code}.json"
        existing_data = load_existing_json(json_file)
        
        translator.target = target_lang
        updated = False

        print(f"📦 Обработка файла: {json_file.name}")

        for key in sorted(keys):
            # Если ключа еще нет в файле — добавляем и переводим
            if key not in existing_data:
                # Пытаемся сделать красивый текст из ключа (например, user_name -> User name)
                base_text = key.replace("_", " ").replace("-", " ")
                
                try:
                    translated_text = translator.translate(base_text)
                    # Если язык русский, делаем первую букву заглавной для красоты
                    if lang_code == "ru" and translated_text:
                        translated_text = translated_text.capitalize()
                except Exception as e:
                    print(f"  ⚠️ Ошибка перевода для '{key}': {e}")
                    translated_text = key # Запасной вариант

                existing_data[key] = translated_text
                print(f"  + Добавлено: '{key}' -> '{translated_text}'")
                updated = True

        if updated:
            save_json(json_file, existing_data)
            print(f"💾 Файл {json_file.name} успешно обновлен!\n")
        else:
            print(f"✨ В файле {json_file.name} всё уже актуально.\n")

    print(" Готово! Все ключи собраны и переведены.")

if __name__ == "__main__":
    main()
