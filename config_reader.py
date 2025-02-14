import json
from typing import Any
from pydantic import BaseModel, ConfigDict, computed_field


class Config(BaseModel):
    model_config = ConfigDict(
        from_attributes=True
    )

    work_time: int
    rest_time: int
    
    file_path: str

    @computed_field
    @property
    def work_time_seconds(self) -> int:
        return self.work_time * 60
    
    @computed_field
    @property
    def rest_time_seconds(self) -> int:
        return self.rest_time * 60

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
