from pydantic import BaseModel


class Image(BaseModel):
    url: str


class GeneralImageResponse(BaseModel):
    quality: bool
    color: str
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
    color: str


class SizeResponse(BaseModel):
    width: float
    height: float
    size: str


class SearchResponse(BaseModel):
    search_result: str  # the path for the similar image


