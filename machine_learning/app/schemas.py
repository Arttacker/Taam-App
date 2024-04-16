from pydantic import BaseModel


class Image(BaseModel):
    url: str


class GeneralImageResponse(BaseModel):
    color: dict
    width: float
    height: float
    size: str
    category: str
    gender: str
    season: str


class QualityResponse(BaseModel):
    quality: bool


class CategoryResponse(BaseModel):
    category: str


class ColorResponse(BaseModel):
    color: dict


class SizeResponse(BaseModel):
    width: float
    height: float
    size: str


class SearchResponse(BaseModel):
    nearest_images: list

