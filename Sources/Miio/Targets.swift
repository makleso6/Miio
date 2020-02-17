//
//  Targets.swift
//  AnyCodable
//
//  Created by Maksim Kolesnik on 15/02/2020.
//

import Foundation

public protocol GetProrRequestTargetType: RequestTargetType { }
extension GetProrRequestTargetType {
    public var method: Miio.Method { .getProp }
}

public struct GetHumidityRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Float> { .init() }
    public var params: ParamsConverible { "humidity" }
    public init() {}
}

public struct GetPowerRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Active> { .init() }
    public var params: ParamsConverible { "power" }
    public init() {}
}

public struct SetPowerRequest: RequestTargetType {
    public var serializer: SingleValueResponseSerializer<String> { .init() }
    public var method: Miio.Method { .setPower }
    public var params: ParamsConverible
    public init(active: Active) {
        self.params = active
    }
}

public struct GetHumidifierModeRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<HumidifierMode> { .init() }
    public var params: ParamsConverible { "mode" }
    public init() {}
}

public struct SetHumidifierModeRequest: RequestTargetType {
    public var serializer: SingleValueResponseSerializer<String> { .init() }
    public var method: Miio.Method { .setMode }
    public var params: ParamsConverible
    public init(mode: HumidifierMode) {
        self.params = mode
    }
}

public struct GetPurifierModeRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<PurifierMode> { .init() }
    public var params: ParamsConverible { "mode" }
    public init() {}
}

public struct SetPurifierModeRequest: RequestTargetType {
    public var serializer: SingleValueResponseSerializer<String> { .init() }
    public var method: Miio.Method { .setMode }
    public var params: ParamsConverible
    public init(mode: PurifierMode) {
        self.params = mode
    }
}

public struct GetDepthRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Float> { .init() }
    public var params: ParamsConverible { "depth" }
    public init() {}
}

public struct GetChildLockRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Active> { .init() }
    public var params: ParamsConverible { "child_lock" }
    public init() {}
}

public struct SetChildLockRequest: RequestTargetType {
    public var serializer: SingleValueResponseSerializer<String> { .init() }
    public var method: Miio.Method { .setChildLock }
    public var params: ParamsConverible
    public init(active: Active) {
        self.params = active
    }
}

public struct GetDryingModeRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Active> { .init() }
    public var params: ParamsConverible { "dry" }
    public init() {}
}

public struct SetDryingModeRequest: RequestTargetType {
    public var serializer: SingleValueResponseSerializer<String> { .init() }
    public var method: Miio.Method { .setDry }
    public var params: ParamsConverible
    public init(active: Active) {
        self.params = active
    }
}

public struct GetTemperatureRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Float> { .init() }
    public var params: ParamsConverible { "temp_dec" }
    public init() {}
}

public struct GetTemperatureRequestCB1: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Float> { .init() }
    public var params: ParamsConverible { "temperature" }
}


public struct GetFavoriteLevelRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Float> { .init() }
    public var params: ParamsConverible { "favorite_level" }
    public init() {}
}

public struct GetAirQualityRequest: GetProrRequestTargetType {
    public var serializer: SingleValueResponseSerializer<Float> { .init() }
    public var params: ParamsConverible { "aqi" }
    public init() {}
}

public struct SetFavoriteLevelRequest: RequestTargetType {
    public var serializer: SingleValueResponseSerializer<String> { .init() }
    public var method: Miio.Method { .setLevelFavorite }
    public var params: ParamsConverible
    public init(level: Float) {
        self.params = level
    }
}
