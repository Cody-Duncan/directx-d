///////////////////////////////////////////////////////////////////////////////
//																			 //
// D3D12RaytracingFallback.h												 //
//																			 //
// Provides a simplified interface for the DX12 Ray Tracing interface that   //
// will use native DX12 ray tracing when available. For drivers that do not  //
// support ray tracing, a fallback compute-shader based solution will be	 //
// used instead.															 //	
//																			 //
///////////////////////////////////////////////////////////////////////////////
module D3D12RaytracingPrototypeHelpers;

import directx.d3d12_1;
import std.bitmanip : bitfields;

struct EMULATED_GPU_POINTER
{
	UINT32 OffsetInBytes;
	UINT32 DescriptorHeapIndex;
}

struct WRAPPED_GPU_POINTER
{
	union
	{
		EMULATED_GPU_POINTER EmulatedGpuPtr;
		D3D12_GPU_VIRTUAL_ADDRESS GpuVA;
	};

	WRAPPED_GPU_POINTER opBinary(string op : "+")(UINT64 offset)
	{
		WRAPPED_GPU_POINTER pointer = *this;
		pointer.GpuVA += offset;
		return pointer;
	}
}

struct D3D12_RAYTRACING_FALLBACK_INSTANCE_DESC
{
	FLOAT[12] Transform;

	mixin(bitfields!(
		UINT, "InstanceID", 24, 
		UINT, "InstanceMask", 8, 
		UINT, "InstanceContributionToHitGroupIndex", 24, 
		UINT, "Flags", 8
	));

	WRAPPED_GPU_POINTER AccelerationStructure;
}


mixin(uuid!(ID3D12RaytracingFallbackStateObject, "539e5c40-df25-4c7d-81d8-6537f54306ed"));
extern (Windows) interface ID3D12RaytracingFallbackStateObject : IUnknown
{
public:
	void *GetShaderIdentifier(
		LPCWSTR pExportName);
	
	UINT64 GetShaderStackSize(
		LPCWSTR pExportName);

	UINT64 GetPipelineStackSize();

	void SetPipelineStackSize(
		UINT64 PipelineStackSizeInBytes);

	ID3D12StateObjectPrototype *GetStateObjectPrototype();
}

struct D3D12_FALLBACK_DISPATCH_RAYS_DESC
{
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE RayGenerationShaderRecord;
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE MissShaderTable;
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE HitGroupTable;
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE CallableShaderTable;
	UINT Width;
	UINT Height;
}

mixin(uuid!(ID3D12RaytracingFallbackCommandList, "348a2a6b-6760-4b78-a9a7-1758b6f78d46"));
extern (Windows) interface ID3D12RaytracingFallbackCommandList : IUnknown
{
public:
	void BuildRaytracingAccelerationStructure(
		const D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC *pDesc);

	void EmitRaytracingAccelerationStructurePostBuildInfo(
		D3D12_GPU_VIRTUAL_ADDRESS_RANGE DestBuffer,
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TYPE InfoType,
		UINT NumSourceAccelerationStructures,
		const D3D12_GPU_VIRTUAL_ADDRESS *pSourceAccelerationStructureData); //_In_reads_(NumSourceAccelerationStructures)

	void CopyRaytracingAccelerationStructure(
		D3D12_GPU_VIRTUAL_ADDRESS_RANGE DestAccelerationStructureData,
		D3D12_GPU_VIRTUAL_ADDRESS SourceAccelerationStructureData,
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE Mode);

	void SetDescriptorHeaps(
		UINT NumDescriptorHeaps,
		const (ID3D12DescriptorHeap *) *ppDescriptorHeaps); //_In_reads_(NumDescriptorHeaps)

	void SetTopLevelAccelerationStructure(
		UINT RootParameterIndex,
		WRAPPED_GPU_POINTER  BufferLocation);

	void DispatchRays(
		ID3D12RaytracingFallbackStateObject *pRaytracingPipelineState,
		const D3D12_FALLBACK_DISPATCH_RAYS_DESC *pDesc);
}

mixin(uuid!(ID3D12RaytracingFallbackDevice, "0a662ea0-ab43-423a-848f-4824ae4b25ba"));
extern (Windows) interface ID3D12RaytracingFallbackDevice : IUnknown
{
public:
	bool UsingRaytracingDriver();

	// Automatically determine how to create WRAPPED_GPU_POINTER based on UsingRaytracingDriver()
	WRAPPED_GPU_POINTER GetWrappedPointerSimple(UINT32 DescriptorHeapIndex, D3D12_GPU_VIRTUAL_ADDRESS GpuVA);

	// Pre-condition: UsingRaytracingDriver() must be false
	WRAPPED_GPU_POINTER GetWrappedPointerFromDescriptorHeapIndex(UINT32 DescriptorHeapIndex, UINT32 OffsetInBytes);

	// Pre-condition: UsingRaytracingDriver() must be true
	WRAPPED_GPU_POINTER GetWrappedPointerFromGpuVA(D3D12_GPU_VIRTUAL_ADDRESS gpuVA);

	D3D12_RESOURCE_STATES GetAccelerationStructureResourceState();

	HRESULT CreateStateObject(
		const D3D12_STATE_OBJECT_DESC *pDesc,
		REFIID riid,
		void **ppStateObject); // COM Outptr

	UINT GetShaderIdentifierSize();

	void GetRaytracingAccelerationStructurePrebuildInfo(
		D3D12_GET_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO_DESC *pDesc,
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO *pInfo);

	void QueryRaytracingCommandList(
		ID3D12GraphicsCommandList *pCommandList, 
		REFIID riid,
		void **ppRaytracingCommandList); // _COM_Outptr_

	HRESULT CreateRootSignature(
		UINT nodeMask,
		const void *pBlobWithRootSignature, // _In_reads_(blobLengthInBytes) 
		SIZE_T blobLengthInBytes,
		REFIID riid,
		void **ppvRootSignature); // _COM_Outptr_

	HRESULT D3D12SerializeVersionedRootSignature(
		const D3D12_VERSIONED_ROOT_SIGNATURE_DESC* pRootSignature,
		ID3DBlob** ppBlob,
		ID3DBlob** ppErrorBlob); // _Always_(_Outptr_opt_result_maybenull_)

	HRESULT D3D12SerializeRootSignature(
		const D3D12_ROOT_SIGNATURE_DESC* pRootSignature,
		D3D_ROOT_SIGNATURE_VERSION Version,
		ID3DBlob** ppBlob,
		ID3DBlob** ppErrorBlob); // _Always_(_Outptr_opt_result_maybenull_)
}

enum CreateRaytracingFallbackDeviceFlags
{
	Nonex0,
	ForceComputeFallbackx1,
};

HRESULT D3D12CreateRaytracingFallbackDevice(
	ID3D12Device *pDevice, 
	CreateRaytracingFallbackDeviceFlags Flags,
	UINT NodeMask,
	REFIID riid,
	void** ppDevice); //_COM_Outptr_opt_