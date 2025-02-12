import json
from typing import Any
from pydantic import BaseModel, ConfigDict


class Config(BaseModel):
    model_config = ConfigDict(
        from_attributes=True
    )

    work_time: int
    rest_time: int
    is_show_time: bool
    is_show_percents: bool

    file_path: str

    @classmethod
    def read_config(cls, file_path: str) -> "Config":
        with open(file_path, "r", encoding="utf-8") as file:
            data = json.load(file)
        return cls(**data, file_path=file_path)
    
    def update_config(self, **kwargs):
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
        with open(self.file_path, "w", encoding="utf-8") as file:
            json.dump(self.model_dump(), file, indent=4)
    
    def update_value(self, key: str, value: Any):
        if hasattr(self, key):
            setattr(self, key, value)
            with open(self.file_path, "r", encoding="utf-8") as file:
                data = json.load(file)
            data[key] = value
            with open(self.file_path, "w", encoding="utf-8") as file:
                json.dump(data, file, indent=4)


config = Config.read_config('config.json')
