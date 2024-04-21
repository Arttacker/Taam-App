from pydantic import BaseModel


class Image(BaseModel):
    url: str


class ImageSave(BaseModel):
    url: str
    category: str


class GeneralImageResponse(BaseModel):
    color: str
    category: str
    gender: str
    season: str


class QualityResponse(BaseModel):
    quality: bool


class SeasonResponse(BaseModel):
    season: str


class GenderResponse(BaseModel):
    gender: str


class CategoryResponse(BaseModel):
    category: str


class ColorResponse(BaseModel):
    color: str


class SizeResponse(BaseModel):
    width: float
    height: float
    size: str


class SearchResponse(BaseModel):
    nearest_images: list

