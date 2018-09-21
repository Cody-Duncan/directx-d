module directx.d3dx12;

public import directx.d3d12;
import core.stdc.string : memcpy;
import std.conv : to;
import std.variant;

struct CD3DX12_DEFAULT {}
extern(Windows) const CD3DX12_DEFAULT D3D12_DEFAULT;

//------------------------------------------------------------------------------------------------
pragma(inline, true) bool opEquals( const ref D3D12_VIEWPORT l, const ref D3D12_VIEWPORT r )
{
	return 
	l.TopLeftX == r.TopLeftX && l.TopLeftY == r.TopLeftY && l.Width == r.Width &&
		l.Height == r.Height && l.MinDepth == r.MinDepth && l.MaxDepth == r.MaxDepth;
}

@safe nothrow unittest
{
	immutable D3D12_VIEWPORT A = 
	{
		TopLeftX : 0.0f,
		TopLeftY : 0.0f,
		Width : 0.0f,
		Height : 0.0f,
		MinDepth : 0.0f,
		MaxDepth : 0.0f
	};

	immutable D3D12_VIEWPORT B = 
	{
		TopLeftX : 0.0f,
		TopLeftY : 0.0f,
		Width : 0.0f,
		Height : 0.0f,
		MinDepth : 0.0f,
		MaxDepth : 0.0f
	};

	assert(A == B);
}

@safe nothrow unittest
{
	immutable D3D12_VIEWPORT A = 
	{
		TopLeftX : 0.0f,
		TopLeftY : 0.0f,
		Width : 0.0f,
		Height : 0.0f,
		MinDepth : 0.0f,
		MaxDepth : 0.0f
	};

	immutable D3D12_VIEWPORT B = 
	{
		TopLeftX : 1.0f,
		TopLeftY : 0.0f,
		Width : 0.0f,
		Height : 0.0f,
		MinDepth : 0.0f,
		MaxDepth : 0.0f
	};

	assert(A != B);
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_RECT
{
	@safe nothrow:

	D3D12_RECT m_rect;
	alias m_rect this;

	this(
		LONG Left,
		LONG Top,
		LONG Right,
		LONG Bottom )
	{
		left = Left;
		top = Top;
		right = Right;
		bottom = Bottom;
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_VIEWPORT
{
	D3D12_VIEWPORT m_viewport;
	alias m_viewport this;

	@safe nothrow this(
		FLOAT topLeftX,
		FLOAT topLeftY,
		FLOAT width,
		FLOAT height,
		FLOAT minDepth = D3D12_MIN_DEPTH,
		FLOAT maxDepth = D3D12_MAX_DEPTH )
	{
		TopLeftX = topLeftX;
		TopLeftY = topLeftY;
		Width = width;
		Height = height;
		MinDepth = minDepth;
		MaxDepth = maxDepth;
	}

	this(
		ID3D12Resource pResource,
		UINT mipSlice = 0,
		FLOAT topLeftX = 0.0f,
		FLOAT topLeftY = 0.0f,
		FLOAT minDepth = D3D12_MIN_DEPTH,
		FLOAT maxDepth = D3D12_MAX_DEPTH )
	{
		immutable D3D12_RESOURCE_DESC Desc = pResource.GetDesc();
		const UINT64 SubresourceWidth = Desc.Width >> mipSlice;
		const UINT64 SubresourceHeight = Desc.Height >> mipSlice;
		switch (Desc.Dimension)
		{
		case D3D12_RESOURCE_DIMENSION_BUFFER:
			TopLeftX = topLeftX;
			TopLeftY = 0.0f;
			Width = Desc.Width - topLeftX;
			Height = 1.0f;
			break;
		case D3D12_RESOURCE_DIMENSION_TEXTURE1D:
			TopLeftX = topLeftX;
			TopLeftY = 0.0f;
			Width = (SubresourceWidth ? SubresourceWidth : 1.0f) - topLeftX;
			Height = 1.0f;
			break;
		case D3D12_RESOURCE_DIMENSION_TEXTURE2D:
		case D3D12_RESOURCE_DIMENSION_TEXTURE3D:
			TopLeftX = topLeftX;
			TopLeftY = topLeftY;
			Width = (SubresourceWidth ? SubresourceWidth : 1.0f) - topLeftX;
			Height = (SubresourceHeight ? SubresourceHeight: 1.0f) - topLeftY;
			break;
		default: break;
		}

		MinDepth = minDepth;
		MaxDepth = maxDepth;
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_BOX
{
	@safe nothrow:

	D3D12_BOX m_box;
	alias m_box this;
	
	this(
		LONG Left,
		LONG Right )
	{
		left = Left;
		top = 0;
		front = 0;
		right = Right;
		bottom = 1;
		back = 1;
	}

	this(
		LONG Left,
		LONG Top,
		LONG Right,
		LONG Bottom )
	{
		left = Left;
		top = Top;
		front = 0;
		right = Right;
		bottom = Bottom;
		back = 1;
	}

	this(
		LONG Left,
		LONG Top,
		LONG Front,
		LONG Right,
		LONG Bottom,
		LONG Back )
	{
		left = Left;
		top = Top;
		front = Front;
		right = Right;
		bottom = Bottom;
		back = Back;
	}
}

pragma(inline, true) bool opEquals( in ref D3D12_BOX l, in ref D3D12_BOX r )
{
	return l.left == r.left && l.top == r.top && l.front == r.front &&
		l.right == r.right && l.bottom == r.bottom && l.back == r.back;
}

@safe nothrow unittest
{
	immutable CD3DX12_BOX A;
	immutable CD3DX12_BOX B;

	assert(A == B);
}

@safe nothrow unittest
{
	immutable CD3DX12_BOX A;
	CD3DX12_BOX B;
	B.top = 1;

	assert(A != B);
}

//------------------------------------------------------------------------------------------------

struct CD3DX12_DEPTH_STENCIL_DESC
{
	@safe nothrow:

	D3D12_DEPTH_STENCIL_DESC m_stencilDesc;
	alias m_stencilDesc this;

	this( CD3DX12_DEFAULT )
	{
		DepthEnable = TRUE;
		DepthWriteMask = D3D12_DEPTH_WRITE_MASK_ALL;
		DepthFunc = D3D12_COMPARISON_FUNC_LESS;
		StencilEnable = FALSE;
		StencilReadMask = D3D12_DEFAULT_STENCIL_READ_MASK;
		StencilWriteMask = D3D12_DEFAULT_STENCIL_WRITE_MASK;
		FrontFace = D3D12_DEPTH_STENCILOP_DESC.defaultStencilOp;
		BackFace = D3D12_DEPTH_STENCILOP_DESC.defaultStencilOp;
	}

	this(
		BOOL depthEnable,
		D3D12_DEPTH_WRITE_MASK depthWriteMask,
		D3D12_COMPARISON_FUNC depthFunc,
		BOOL stencilEnable,
		UINT8 stencilReadMask,
		UINT8 stencilWriteMask,
		D3D12_STENCIL_OP frontStencilFailOp,
		D3D12_STENCIL_OP frontStencilDepthFailOp,
		D3D12_STENCIL_OP frontStencilPassOp,
		D3D12_COMPARISON_FUNC frontStencilFunc,
		D3D12_STENCIL_OP backStencilFailOp,
		D3D12_STENCIL_OP backStencilDepthFailOp,
		D3D12_STENCIL_OP backStencilPassOp,
		D3D12_COMPARISON_FUNC backStencilFunc )
	{
		DepthEnable = depthEnable;
		DepthWriteMask = depthWriteMask;
		DepthFunc = depthFunc;
		StencilEnable = stencilEnable;
		StencilReadMask = stencilReadMask;
		StencilWriteMask = stencilWriteMask;
		FrontFace.StencilFailOp = frontStencilFailOp;
		FrontFace.StencilDepthFailOp = frontStencilDepthFailOp;
		FrontFace.StencilPassOp = frontStencilPassOp;
		FrontFace.StencilFunc = frontStencilFunc;
		BackFace.StencilFailOp = backStencilFailOp;
		BackFace.StencilDepthFailOp = backStencilDepthFailOp;
		BackFace.StencilPassOp = backStencilPassOp;
		BackFace.StencilFunc = backStencilFunc;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_DEPTH_STENCIL_DESC testStencilDesc;
	cast(void)testStencilDesc; //unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_DEPTH_STENCIL_DESC1
{
	@safe nothrow:

	D3D12_DEPTH_STENCIL_DESC1 m_depthStencilDesc;
	alias m_depthStencilDesc this;

	this( const D3D12_DEPTH_STENCIL_DESC o )
	{
		DepthEnable				  = o.DepthEnable;
		DepthWriteMask			   = o.DepthWriteMask;
		DepthFunc					= o.DepthFunc;
		StencilEnable				= o.StencilEnable;
		StencilReadMask			  = o.StencilReadMask;
		StencilWriteMask			 = o.StencilWriteMask;
		FrontFace.StencilFailOp	  = o.FrontFace.StencilFailOp;
		FrontFace.StencilDepthFailOp = o.FrontFace.StencilDepthFailOp;
		FrontFace.StencilPassOp	  = o.FrontFace.StencilPassOp;
		FrontFace.StencilFunc		= o.FrontFace.StencilFunc;
		BackFace.StencilFailOp	   = o.BackFace.StencilFailOp;
		BackFace.StencilDepthFailOp  = o.BackFace.StencilDepthFailOp;
		BackFace.StencilPassOp	   = o.BackFace.StencilPassOp;
		BackFace.StencilFunc		 = o.BackFace.StencilFunc;
		DepthBoundsTestEnable		= FALSE;
	}

	this( const D3D12_DEPTH_STENCIL_DESC1 o )
	{
		DepthEnable				  = o.DepthEnable;
		DepthWriteMask			   = o.DepthWriteMask;
		DepthFunc					= o.DepthFunc;
		StencilEnable				= o.StencilEnable;
		StencilReadMask			  = o.StencilReadMask;
		StencilWriteMask			 = o.StencilWriteMask;
		FrontFace.StencilFailOp	  = o.FrontFace.StencilFailOp;
		FrontFace.StencilDepthFailOp = o.FrontFace.StencilDepthFailOp;
		FrontFace.StencilPassOp	  = o.FrontFace.StencilPassOp;
		FrontFace.StencilFunc		= o.FrontFace.StencilFunc;
		BackFace.StencilFailOp	   = o.BackFace.StencilFailOp;
		BackFace.StencilDepthFailOp  = o.BackFace.StencilDepthFailOp;
		BackFace.StencilPassOp	   = o.BackFace.StencilPassOp;
		BackFace.StencilFunc		 = o.BackFace.StencilFunc;
		DepthBoundsTestEnable		= o.DepthBoundsTestEnable;
	}

	this( CD3DX12_DEFAULT )
	{
		DepthEnable = TRUE;
		DepthWriteMask = D3D12_DEPTH_WRITE_MASK_ALL;
		DepthFunc = D3D12_COMPARISON_FUNC_LESS;
		StencilEnable = FALSE;
		StencilReadMask = D3D12_DEFAULT_STENCIL_READ_MASK;
		StencilWriteMask = D3D12_DEFAULT_STENCIL_WRITE_MASK;
		FrontFace = D3D12_DEPTH_STENCILOP_DESC.defaultStencilOp;
		BackFace = D3D12_DEPTH_STENCILOP_DESC.defaultStencilOp;
		DepthBoundsTestEnable = FALSE;
	}

	this(
		BOOL depthEnable,
		D3D12_DEPTH_WRITE_MASK depthWriteMask,
		D3D12_COMPARISON_FUNC depthFunc,
		BOOL stencilEnable,
		UINT8 stencilReadMask,
		UINT8 stencilWriteMask,
		D3D12_STENCIL_OP frontStencilFailOp,
		D3D12_STENCIL_OP frontStencilDepthFailOp,
		D3D12_STENCIL_OP frontStencilPassOp,
		D3D12_COMPARISON_FUNC frontStencilFunc,
		D3D12_STENCIL_OP backStencilFailOp,
		D3D12_STENCIL_OP backStencilDepthFailOp,
		D3D12_STENCIL_OP backStencilPassOp,
		D3D12_COMPARISON_FUNC backStencilFunc,
		BOOL depthBoundsTestEnable )
	{
		DepthEnable = depthEnable;
		DepthWriteMask = depthWriteMask;
		DepthFunc = depthFunc;
		StencilEnable = stencilEnable;
		StencilReadMask = stencilReadMask;
		StencilWriteMask = stencilWriteMask;
		FrontFace.StencilFailOp = frontStencilFailOp;
		FrontFace.StencilDepthFailOp = frontStencilDepthFailOp;
		FrontFace.StencilPassOp = frontStencilPassOp;
		FrontFace.StencilFunc = frontStencilFunc;
		BackFace.StencilFailOp = backStencilFailOp;
		BackFace.StencilDepthFailOp = backStencilDepthFailOp;
		BackFace.StencilPassOp = backStencilPassOp;
		BackFace.StencilFunc = backStencilFunc;
		DepthBoundsTestEnable = depthBoundsTestEnable;
	}

	// once you define your own opCast, it overrides any built in ones that exist
	// thanks to the 'alias this'.
	// Define opcasts for... back to itself.

	D3D12_DEPTH_STENCIL_DESC opCast(T : D3D12_DEPTH_STENCIL_DESC)() const
	{
		D3D12_DEPTH_STENCIL_DESC D;
		D.DepthEnable				  = DepthEnable;
		D.DepthWriteMask			   = DepthWriteMask;
		D.DepthFunc					= DepthFunc;
		D.StencilEnable				= StencilEnable;
		D.StencilReadMask			  = StencilReadMask;
		D.StencilWriteMask			 = StencilWriteMask;
		D.FrontFace.StencilFailOp	  = FrontFace.StencilFailOp;
		D.FrontFace.StencilDepthFailOp = FrontFace.StencilDepthFailOp;
		D.FrontFace.StencilPassOp	  = FrontFace.StencilPassOp;
		D.FrontFace.StencilFunc		= FrontFace.StencilFunc;
		D.BackFace.StencilFailOp	   = BackFace.StencilFailOp;
		D.BackFace.StencilDepthFailOp  = BackFace.StencilDepthFailOp;
		D.BackFace.StencilPassOp	   = BackFace.StencilPassOp;
		D.BackFace.StencilFunc		 = BackFace.StencilFunc;
		return D;
	}

	D3D12_DEPTH_STENCIL_DESC1 opCast(T : D3D12_DEPTH_STENCIL_DESC1)() const
	{
		return m_depthStencilDesc;
	}

	CD3DX12_DEPTH_STENCIL_DESC1 opCast(T : CD3DX12_DEPTH_STENCIL_DESC1)() const
	{
		return this;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_DEPTH_STENCIL_DESC1 testStencilDesc = CD3DX12_DEPTH_STENCIL_DESC1(D3D12_DEFAULT);

	D3D12_DEPTH_STENCIL_DESC copyToVariable = cast(D3D12_DEPTH_STENCIL_DESC)(testStencilDesc);

	assert(copyToVariable.DepthEnable == TRUE);
	assert(copyToVariable.DepthWriteMask == D3D12_DEPTH_WRITE_MASK_ALL);
	assert(copyToVariable.DepthFunc == D3D12_COMPARISON_FUNC_LESS);
	assert(copyToVariable.StencilEnable == FALSE);
	assert(copyToVariable.StencilReadMask == D3D12_DEFAULT_STENCIL_READ_MASK);
	assert(copyToVariable.StencilWriteMask == D3D12_DEFAULT_STENCIL_WRITE_MASK);
	assert(copyToVariable.FrontFace == D3D12_DEPTH_STENCILOP_DESC.defaultStencilOp);
	assert(copyToVariable.BackFace == D3D12_DEPTH_STENCILOP_DESC.defaultStencilOp);
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_BLEND_DESC
{
	@safe nothrow:

	D3D12_BLEND_DESC m_blendDesc;
	alias m_blendDesc this;

	this( const ref D3D12_BLEND_DESC o )
	{
		m_blendDesc = o;
	}

	this( CD3DX12_DEFAULT )
	{
		AlphaToCoverageEnable = FALSE;
		IndependentBlendEnable = FALSE;
		const D3D12_RENDER_TARGET_BLEND_DESC defaultRenderTargetBlendDesc =
		{
			FALSE,FALSE,
			D3D12_BLEND_ONE, D3D12_BLEND_ZERO, D3D12_BLEND_OP_ADD,
			D3D12_BLEND_ONE, D3D12_BLEND_ZERO, D3D12_BLEND_OP_ADD,
			D3D12_LOGIC_OP_NOOP,
			D3D12_COLOR_WRITE_ENABLE_ALL,
		};
		for (UINT i = 0; i < D3D12_SIMULTANEOUS_RENDER_TARGET_COUNT; ++i)
		{
			RenderTarget[ i ] = defaultRenderTargetBlendDesc;
		}
			
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_BLEND_DESC testBlendDesc = CD3DX12_BLEND_DESC(D3D12_DEFAULT);
	cast(void)(testBlendDesc); //unused
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_RASTERIZER_DESC
{
	D3D12_RASTERIZER_DESC m_rasterizerDesc;
	alias m_rasterizerDesc this;

	@safe nothrow:

	this( const ref D3D12_RASTERIZER_DESC o )
	{
		m_rasterizerDesc = o;
	}

	this( CD3DX12_DEFAULT )
	{
		FillMode = D3D12_FILL_MODE_SOLID;
		CullMode = D3D12_CULL_MODE_BACK;
		FrontCounterClockwise = FALSE;
		DepthBias = D3D12_DEFAULT_DEPTH_BIAS;
		DepthBiasClamp = D3D12_DEFAULT_DEPTH_BIAS_CLAMP;
		SlopeScaledDepthBias = D3D12_DEFAULT_SLOPE_SCALED_DEPTH_BIAS;
		DepthClipEnable = TRUE;
		MultisampleEnable = FALSE;
		AntialiasedLineEnable = FALSE;
		ForcedSampleCount = 0;
		ConservativeRaster = D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF;
	}

	this(
		D3D12_FILL_MODE fillMode,
		D3D12_CULL_MODE cullMode,
		BOOL frontCounterClockwise,
		INT depthBias,
		FLOAT depthBiasClamp,
		FLOAT slopeScaledDepthBias,
		BOOL depthClipEnable,
		BOOL multisampleEnable,
		BOOL antialiasedLineEnable, 
		UINT forcedSampleCount, 
		D3D12_CONSERVATIVE_RASTERIZATION_MODE conservativeRaster)
	{
		FillMode = fillMode;
		CullMode = cullMode;
		FrontCounterClockwise = frontCounterClockwise;
		DepthBias = depthBias;
		DepthBiasClamp = depthBiasClamp;
		SlopeScaledDepthBias = slopeScaledDepthBias;
		DepthClipEnable = depthClipEnable;
		MultisampleEnable = multisampleEnable;
		AntialiasedLineEnable = antialiasedLineEnable;
		ForcedSampleCount = forcedSampleCount;
		ConservativeRaster = conservativeRaster;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_RASTERIZER_DESC testRasterizerDesc = CD3DX12_RASTERIZER_DESC(D3D12_DEFAULT);
	cast(void)(testRasterizerDesc); // unused
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_RESOURCE_ALLOCATION_INFO
{
	D3D12_RESOURCE_ALLOCATION_INFO m_resourceAllocationInfo;
	alias m_resourceAllocationInfo this;
	
	this( const ref D3D12_RESOURCE_ALLOCATION_INFO o ) nothrow
	{
		m_resourceAllocationInfo = o;
	}

	@safe nothrow:

	this(
		UINT64 size,
		UINT64 alignment )
	{
		SizeInBytes = size;
		Alignment = alignment;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_RESOURCE_ALLOCATION_INFO testResourceAllocationInfo = CD3DX12_RESOURCE_ALLOCATION_INFO(0, 0);
	cast(void)(testResourceAllocationInfo); //unused
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_HEAP_PROPERTIES
{
	D3D12_HEAP_PROPERTIES m_heapProperties;
	alias m_heapProperties this;
	
	@safe nothrow:

	this(const ref D3D12_HEAP_PROPERTIES o)
	{
		m_heapProperties = o;
	}

	this( 
		D3D12_CPU_PAGE_PROPERTY cpuPageProperty, 
		D3D12_MEMORY_POOL memoryPoolPreference,
		UINT creationNodeMask = 1, 
		UINT nodeMask = 1 )
	{
		Type = D3D12_HEAP_TYPE_CUSTOM;
		CPUPageProperty = cpuPageProperty;
		MemoryPoolPreference = memoryPoolPreference;
		CreationNodeMask = creationNodeMask;
		VisibleNodeMask = nodeMask;
	}

	this( 
		D3D12_HEAP_TYPE type, 
		UINT creationNodeMask = 1, 
		UINT nodeMask = 1 )
	{
		Type = type;
		CPUPageProperty = D3D12_CPU_PAGE_PROPERTY_UNKNOWN;
		MemoryPoolPreference = D3D12_MEMORY_POOL_UNKNOWN;
		CreationNodeMask = creationNodeMask;
		VisibleNodeMask = nodeMask;
	}
}

bool IsCPUAccessible(const ref D3D12_HEAP_PROPERTIES heapProperties) pure nothrow @safe @nogc
{
	return heapProperties.Type == D3D12_HEAP_TYPE_UPLOAD || heapProperties.Type == D3D12_HEAP_TYPE_READBACK || (heapProperties.Type == D3D12_HEAP_TYPE_CUSTOM &&
		(heapProperties.CPUPageProperty == D3D12_CPU_PAGE_PROPERTY_WRITE_COMBINE || heapProperties.CPUPageProperty == D3D12_CPU_PAGE_PROPERTY_WRITE_BACK));
}

pragma(inline, true) bool opEquals( const ref D3D12_HEAP_PROPERTIES l, const ref D3D12_HEAP_PROPERTIES r )
{
	return 
		l.Type == r.Type && 
		l.CPUPageProperty == r.CPUPageProperty && 
		l.MemoryPoolPreference == r.MemoryPoolPreference &&
		l.CreationNodeMask == r.CreationNodeMask &&
		l.VisibleNodeMask == r.VisibleNodeMask;
}

@safe nothrow unittest
{
	CD3DX12_HEAP_PROPERTIES testHeapProperties = CD3DX12_HEAP_PROPERTIES(D3D12_HEAP_TYPE_DEFAULT, 1, 1);
	assert(!testHeapProperties.IsCPUAccessible());
}

@safe nothrow unittest
{
	immutable CD3DX12_HEAP_PROPERTIES testHeapPropertiesA = CD3DX12_HEAP_PROPERTIES(D3D12_HEAP_TYPE_DEFAULT, 1, 1);
	immutable CD3DX12_HEAP_PROPERTIES testHeapPropertiesB = CD3DX12_HEAP_PROPERTIES(D3D12_HEAP_TYPE_UPLOAD, 1, 1);
	assert(testHeapPropertiesA == testHeapPropertiesA);
	assert(testHeapPropertiesA != testHeapPropertiesB);
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_HEAP_DESC
{
	D3D12_HEAP_DESC m_heapDesc;
	alias m_heapDesc this;

	@safe nothrow:

	this(const ref D3D12_HEAP_DESC o)
	{
		m_heapDesc = o;
	}

	this( 
		UINT64 size, 
		D3D12_HEAP_PROPERTIES properties, 
		UINT64 alignment = 0, 
		D3D12_HEAP_FLAGS flags = D3D12_HEAP_FLAG_NONE )
	{
		SizeInBytes = size;
		Properties = properties;
		Alignment = alignment;
		Flags = flags;
	}

	this( 
		UINT64 size, 
		D3D12_HEAP_TYPE type, 
		UINT64 alignment = 0, 
		D3D12_HEAP_FLAGS flags = D3D12_HEAP_FLAG_NONE )
	{
		SizeInBytes = size;
		Properties = CD3DX12_HEAP_PROPERTIES( type );
		Alignment = alignment;
		Flags = flags;
	}

	this( 
		UINT64 size, 
		D3D12_CPU_PAGE_PROPERTY cpuPageProperty, 
		D3D12_MEMORY_POOL memoryPoolPreference, 
		UINT64 alignment = 0, 
		D3D12_HEAP_FLAGS flags = D3D12_HEAP_FLAG_NONE )
	{
		SizeInBytes = size;
		Properties = CD3DX12_HEAP_PROPERTIES( cpuPageProperty, memoryPoolPreference );
		Alignment = alignment;
		Flags = flags;
	}

	this( 
		const ref D3D12_RESOURCE_ALLOCATION_INFO resAllocInfo,
		D3D12_HEAP_PROPERTIES properties, 
		D3D12_HEAP_FLAGS flags = D3D12_HEAP_FLAG_NONE )
	{
		SizeInBytes = resAllocInfo.SizeInBytes;
		Properties = properties;
		Alignment = resAllocInfo.Alignment;
		Flags = flags;
	}

	this( 
		const ref D3D12_RESOURCE_ALLOCATION_INFO resAllocInfo,
		D3D12_HEAP_TYPE type, 
		D3D12_HEAP_FLAGS flags = D3D12_HEAP_FLAG_NONE )
	{
		SizeInBytes = resAllocInfo.SizeInBytes;
		Properties = CD3DX12_HEAP_PROPERTIES( type );
		Alignment = resAllocInfo.Alignment;
		Flags = flags;
	}

	this( 
		const ref D3D12_RESOURCE_ALLOCATION_INFO resAllocInfo,
		D3D12_CPU_PAGE_PROPERTY cpuPageProperty, 
		D3D12_MEMORY_POOL memoryPoolPreference, 
		D3D12_HEAP_FLAGS flags = D3D12_HEAP_FLAG_NONE )
	{
		SizeInBytes = resAllocInfo.SizeInBytes;
		Properties = CD3DX12_HEAP_PROPERTIES( cpuPageProperty, memoryPoolPreference );
		Alignment = resAllocInfo.Alignment;
		Flags = flags;
	}

	bool IsCPUAccessible() const
	{ 
		return Properties.IsCPUAccessible(); 
	}
}

pragma(inline, true) bool opEquals( const ref D3D12_HEAP_DESC l, const ref D3D12_HEAP_DESC r )
{
	return l.SizeInBytes == r.SizeInBytes &&
		l.Properties == r.Properties && 
		l.Alignment == r.Alignment &&
		l.Flags == r.Flags;
}

@safe nothrow unittest
{
	CD3DX12_HEAP_PROPERTIES testHeapProperties = CD3DX12_HEAP_PROPERTIES(D3D12_HEAP_TYPE_DEFAULT, 1, 1);

	CD3DX12_HEAP_DESC testHeapDesc = CD3DX12_HEAP_DESC(64, testHeapProperties, 0, D3D12_HEAP_FLAG_NONE);
	assert(!testHeapDesc.IsCPUAccessible());
}

@safe nothrow unittest
{
	CD3DX12_HEAP_PROPERTIES testHeapProperties = CD3DX12_HEAP_PROPERTIES(D3D12_HEAP_TYPE_DEFAULT, 1, 1);

	immutable CD3DX12_HEAP_DESC testHeapDescA = CD3DX12_HEAP_DESC(64, testHeapProperties, 0, D3D12_HEAP_FLAG_NONE);
	immutable CD3DX12_HEAP_DESC testHeapDescB = CD3DX12_HEAP_DESC(128, testHeapProperties, 0, D3D12_HEAP_FLAG_NONE);
	assert(testHeapDescA == testHeapDescA);
	assert(testHeapDescA != testHeapDescB);
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_CLEAR_VALUE 
{
	D3D12_CLEAR_VALUE m_clearValue;
	alias m_clearValue this;

	@safe nothrow:

	this(const ref D3D12_CLEAR_VALUE o)
	{
		m_clearValue = o;
	}

	this( 
		DXGI_FORMAT format, 
		const FLOAT[4] color ) @trusted
	{
		Format = format;
		memcpy( Color.ptr, color.ptr, Color.sizeof );
	}

	this( 
		DXGI_FORMAT format, 
		FLOAT depth,
		UINT8 stencil ) @trusted nothrow
	{
		Format = format;
		/* Use memcpy to preserve NAN values */
		memcpy( &DepthStencil.Depth, &depth, depth.sizeof );
		DepthStencil.Stencil = stencil;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_CLEAR_VALUE testClearValue = CD3DX12_CLEAR_VALUE(DXGI_FORMAT_R32G32B32A32_FLOAT, [1.0f, 1.0f, 1.0f, 1.0f]);
	cast(void)(testClearValue); // unused
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_RANGE
{
	D3D12_RANGE m_range;
	alias m_range this;
	
	this(const ref D3D12_RANGE o) 
	{
		m_range = o;
	}

	this( 
		SIZE_T begin, 
		SIZE_T end )
	{
		Begin = begin;
		End = end;
	}
}

unittest
{
	immutable CD3DX12_RANGE testRange = CD3DX12_RANGE(0, 10);
	cast(void)(testRange); // unused
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_RANGE_UINT64
{
	D3D12_RANGE_UINT64 m_D3D12_RANGE_UINT64;
	alias m_D3D12_RANGE_UINT64 this;

	@safe nothrow:

	this(const ref D3D12_RANGE_UINT64 o)
	{
		m_D3D12_RANGE_UINT64 = o;
	}

	this( 
		UINT64 begin, 
		UINT64 end )
	{
		Begin = begin;
		End = end;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_RANGE_UINT64 testRange64 = CD3DX12_RANGE_UINT64(UINT64(0), UINT64(10));
	cast(void)(testRange64); // unused
}

////------------------------------------------------------------------------------------------------
struct CD3DX12_SUBRESOURCE_RANGE_UINT64
{
	D3D12_SUBRESOURCE_RANGE_UINT64 m_D3D12_SUBRESOURCE_RANGE_UINT64;
	alias m_D3D12_SUBRESOURCE_RANGE_UINT64 this;

	@safe nothrow:

	this(const ref D3D12_SUBRESOURCE_RANGE_UINT64 o)
	{
		m_D3D12_SUBRESOURCE_RANGE_UINT64 = o;
	}
	this( 
		UINT subresource,
		const ref D3D12_RANGE_UINT64 range )
	{
		Subresource = subresource;
		Range = range;
	}
	this( 
		UINT subresource,
		UINT64 begin, 
		UINT64 end )
	{
		Subresource = subresource;
		Range.Begin = begin;
		Range.End = end;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_RANGE_UINT64 testRange64 = CD3DX12_RANGE_UINT64(UINT64(0), UINT64(10));
	immutable CD3DX12_SUBRESOURCE_RANGE_UINT64 testSubresourceRangeUINT64 = CD3DX12_SUBRESOURCE_RANGE_UINT64(0, testRange64);
	cast(void)(testSubresourceRangeUINT64); //unused
}


//------------------------------------------------------------------------------------------------
struct CD3DX12_SHADER_BYTECODE
{
	D3D12_SHADER_BYTECODE m_D3D12_SHADER_BYTECODE;
	alias m_D3D12_SHADER_BYTECODE this;

	this(const ref D3D12_SHADER_BYTECODE o) pure nothrow @nogc @safe
	{
		m_D3D12_SHADER_BYTECODE = o;
	}

	this(ID3DBlob* pShaderBlob ) // _In_
	{
		pShaderBytecode = pShaderBlob.GetBufferPointer();
		BytecodeLength = pShaderBlob.GetBufferSize();
	}

	this(
		const void* _pShaderBytecode,
		SIZE_T bytecodeLength ) pure nothrow @nogc @safe
	{
		pShaderBytecode = _pShaderBytecode;
		BytecodeLength = bytecodeLength;
	}
}

@safe nothrow unittest
{
	const CD3DX12_SHADER_BYTECODE testShaderBytecode = const CD3DX12_SHADER_BYTECODE(null, 0);
	cast(void)(testShaderBytecode); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_TILED_RESOURCE_COORDINATE
{
	D3D12_TILED_RESOURCE_COORDINATE m_D3D12_TILED_RESOURCE_COORDINATE;
	alias m_D3D12_TILED_RESOURCE_COORDINATE this;

	@safe nothrow:

	this(const ref D3D12_TILED_RESOURCE_COORDINATE o)
	{
		m_D3D12_TILED_RESOURCE_COORDINATE = o;
	}
	
	this( 
		UINT x, 
		UINT y, 
		UINT z, 
		UINT subresource ) 
	{
		X = x;
		Y = y;
		Z = z;
		Subresource = subresource;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_TILED_RESOURCE_COORDINATE testTiledResourceCoordinate = CD3DX12_TILED_RESOURCE_COORDINATE(0, 0, 0, 0);
	cast(void)(testTiledResourceCoordinate); //unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_TILE_REGION_SIZE
{
	D3D12_TILE_REGION_SIZE m_D3D12_TILE_REGION_SIZE;
	alias m_D3D12_TILE_REGION_SIZE this;

	@safe nothrow:

	this(const ref D3D12_TILE_REGION_SIZE o)
	{
		m_D3D12_TILE_REGION_SIZE = o;
	}

	this( 
		UINT numTiles, 
		BOOL useBox, 
		UINT width, 
		UINT16 height, 
		UINT16 depth ) 
	{
		NumTiles = numTiles;
		UseBox = useBox;
		Width = width;
		Height = height;
		Depth = depth;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_TILE_REGION_SIZE testTileRegionSize = CD3DX12_TILE_REGION_SIZE(UINT(0), false, UINT(0), UINT16(0), UINT16(0));
	cast(void)(testTileRegionSize); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_SUBRESOURCE_TILING
{
	D3D12_SUBRESOURCE_TILING m_D3D12_SUBRESOURCE_TILING;
	alias m_D3D12_SUBRESOURCE_TILING this;

	@safe nothrow:

	this(const ref D3D12_SUBRESOURCE_TILING o)
	{
		m_D3D12_SUBRESOURCE_TILING = o;
	}
	
	this( 
		UINT widthInTiles, 
		UINT16 heightInTiles, 
		UINT16 depthInTiles, 
		UINT startTileIndexInOverallResource ) 
	{
		WidthInTiles = widthInTiles;
		HeightInTiles = heightInTiles;
		DepthInTiles = depthInTiles;
		StartTileIndexInOverallResource = startTileIndexInOverallResource;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_SUBRESOURCE_TILING testSubresourceTiling = CD3DX12_SUBRESOURCE_TILING(UINT(0), UINT16(0), UINT16(0), UINT(0));
	cast(void)(testSubresourceTiling); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_TILE_SHAPE
{
	D3D12_TILE_SHAPE m_D3D12_TILE_SHAPE;
	alias m_D3D12_TILE_SHAPE this;

	@safe nothrow:

	this(const ref D3D12_TILE_SHAPE o)
	{
		m_D3D12_TILE_SHAPE = o;
	}

	this( 
		UINT widthInTexels, 
		UINT heightInTexels, 
		UINT depthInTexels ) 
	{
		WidthInTexels = widthInTexels;
		HeightInTexels = heightInTexels;
		DepthInTexels = depthInTexels;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_TILE_SHAPE testTileShape = CD3DX12_TILE_SHAPE(UINT(0), UINT(0), UINT(0));
	cast(void)(testTileShape); //unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_RESOURCE_BARRIER
{
	D3D12_RESOURCE_BARRIER m_D3D12_RESOURCE_BARRIER;
	alias m_D3D12_RESOURCE_BARRIER this;

	this(const ref D3D12_RESOURCE_BARRIER o) @trusted
	{
		// Error: cannot implicitly convert expression o of type const(D3D12_RESOURCE_BARRIER) to D3D12_RESOURCE_BARRIER
		// My guess is that this is because D3D12_RESOURCE_BARRIER contains a union.
		m_D3D12_RESOURCE_BARRIER = cast(D3D12_RESOURCE_BARRIER)o; 
	}

	nothrow:

	static pragma(inline, true) CD3DX12_RESOURCE_BARRIER Transition(
		ID3D12Resource pResource, // _In_
		D3D12_RESOURCE_STATES stateBefore,
		D3D12_RESOURCE_STATES stateAfter,
		UINT subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES,
		D3D12_RESOURCE_BARRIER_FLAGS flags = D3D12_RESOURCE_BARRIER_FLAG_NONE)
	{
		CD3DX12_RESOURCE_BARRIER result = CD3DX12_RESOURCE_BARRIER();
		//ZeroMemory(&result, result.sizeof); // should already be initialized.
		result.Type = D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
		result.Flags = flags;
		result.m_D3D12_RESOURCE_BARRIER.Transition.pResource = pResource;
		result.m_D3D12_RESOURCE_BARRIER.Transition.StateBefore = stateBefore;
		result.m_D3D12_RESOURCE_BARRIER.Transition.StateAfter = stateAfter;
		result.m_D3D12_RESOURCE_BARRIER.Transition.Subresource = subresource;
		return result;
	}

	static pragma(inline, true) CD3DX12_RESOURCE_BARRIER Aliasing(
		ID3D12Resource pResourceBefore, // _In_
		ID3D12Resource pResourceAfter) // _In_
	{
		CD3DX12_RESOURCE_BARRIER result = CD3DX12_RESOURCE_BARRIER();
		//ZeroMemory(&result, result.sizeof); // should already be initialized.
		result.Type = D3D12_RESOURCE_BARRIER_TYPE_ALIASING;
		result.m_D3D12_RESOURCE_BARRIER.Aliasing.pResourceBefore = pResourceBefore;
		result.m_D3D12_RESOURCE_BARRIER.Aliasing.pResourceAfter = pResourceAfter;
		return result;
	}

	static pragma(inline, true) CD3DX12_RESOURCE_BARRIER UAV(
		ID3D12Resource pResource) // _In_
	{
		CD3DX12_RESOURCE_BARRIER result = CD3DX12_RESOURCE_BARRIER();
		//ZeroMemory(&result, result.sizeof); // should already be initialized.
		result.Type = D3D12_RESOURCE_BARRIER_TYPE_UAV;
		result.m_D3D12_RESOURCE_BARRIER.UAV.pResource = pResource;
		return result;
	}
}

nothrow unittest
{
	const CD3DX12_RESOURCE_BARRIER testResourceBarrier_Transition = 
		const CD3DX12_RESOURCE_BARRIER.Transition(
			null, 
			D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER, 
			D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER, 
			D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES, 
			D3D12_RESOURCE_BARRIER_FLAG_NONE);
	
	cast(void)(testResourceBarrier_Transition); // unused
}

nothrow unittest
{
	const CD3DX12_RESOURCE_BARRIER testResourceBarrier_Aliasing = 
		const CD3DX12_RESOURCE_BARRIER.Aliasing(
			null, 
			null);
	
	cast(void)(testResourceBarrier_Aliasing); // unused
}

nothrow unittest
{
	const CD3DX12_RESOURCE_BARRIER testResourceBarrier_UAV = 
		const CD3DX12_RESOURCE_BARRIER.UAV(
			null);
	
	cast(void)(testResourceBarrier_UAV); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_PACKED_MIP_INFO
{
	D3D12_PACKED_MIP_INFO m_D3D12_PACKED_MIP_INFO;
	alias m_D3D12_PACKED_MIP_INFO this;

	@safe nothrow:

	this(const ref D3D12_PACKED_MIP_INFO o)
	{
		m_D3D12_PACKED_MIP_INFO = o;
	}

	this( 
		UINT8 numStandardMips, 
		UINT8 numPackedMips, 
		UINT numTilesForPackedMips, 
		UINT startTileIndexInOverallResource ) 
	{
		NumStandardMips = numStandardMips;
		NumPackedMips = numPackedMips;
		NumTilesForPackedMips = numTilesForPackedMips;
		StartTileIndexInOverallResource = startTileIndexInOverallResource;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_PACKED_MIP_INFO testPackedMipInfo = CD3DX12_PACKED_MIP_INFO(UINT8(0), UINT8(0), UINT(0), UINT(0));
	cast(void)(testPackedMipInfo); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_SUBRESOURCE_FOOTPRINT
{
	D3D12_SUBRESOURCE_FOOTPRINT m_D3D12_SUBRESOURCE_FOOTPRINT;
	alias m_D3D12_SUBRESOURCE_FOOTPRINT this;

	this(const ref D3D12_SUBRESOURCE_FOOTPRINT o) @safe nothrow
	{
		m_D3D12_SUBRESOURCE_FOOTPRINT = o;
	}

	this( 
		DXGI_FORMAT format, 
		UINT width, 
		UINT height, 
		UINT depth, 
		UINT rowPitch ) @safe nothrow
	{
		Format = format;
		Width = width;
		Height = height;
		Depth = depth;
		RowPitch = rowPitch;
	}

	this( 
		const ref D3D12_RESOURCE_DESC resDesc, 
		UINT rowPitch ) @safe
	{
		Format = resDesc.Format;
		Width = to!UINT( resDesc.Width ); // can throw an exception
		Height = resDesc.Height;
		Depth = (resDesc.Dimension == D3D12_RESOURCE_DIMENSION_TEXTURE3D ? resDesc.DepthOrArraySize : 1);
		RowPitch = rowPitch;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_SUBRESOURCE_FOOTPRINT testSubresourceFootprint = 
		CD3DX12_SUBRESOURCE_FOOTPRINT(DXGI_FORMAT_UNKNOWN, UINT(0), UINT(0), UINT(0), UINT(0));
	cast(void)(testSubresourceFootprint); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_TEXTURE_COPY_LOCATION
{
	D3D12_TEXTURE_COPY_LOCATION m_D3D12_TEXTURE_COPY_LOCATION;
	alias m_D3D12_TEXTURE_COPY_LOCATION this;

	this(const ref D3D12_TEXTURE_COPY_LOCATION o)
	{
		// Error: cannot implicitly convert expression o of type const(D3D12_RESOURCE_BARRIER) to D3D12_RESOURCE_BARRIER
		// My guess is that this is because D3D12_RESOURCE_BARRIER contains a union.
		m_D3D12_TEXTURE_COPY_LOCATION = cast(D3D12_TEXTURE_COPY_LOCATION)(o);
	}

	this(ID3D12Resource pRes) 
	{
		pResource = pRes; 
	}

	this(
		ID3D12Resource pRes, 
		const ref D3D12_PLACED_SUBRESOURCE_FOOTPRINT Footprint)
	{
		pResource = pRes;
		Type = D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
		PlacedFootprint = Footprint;
	}

	this(
		ID3D12Resource pRes, 
		UINT Sub)
	{
		pResource = pRes;
		Type = D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX;
		SubresourceIndex = Sub;
	}

	D3D12_TEXTURE_COPY_LOCATION * ptr() { return &m_D3D12_TEXTURE_COPY_LOCATION; }
}

unittest
{
	const CD3DX12_TEXTURE_COPY_LOCATION testTextureCopyLocation = const CD3DX12_TEXTURE_COPY_LOCATION(null, UINT(0));
	cast(void)(testTextureCopyLocation); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_DESCRIPTOR_RANGE
{
	D3D12_DESCRIPTOR_RANGE m_D3D12_DESCRIPTOR_RANGE;
	alias m_D3D12_DESCRIPTOR_RANGE this;

	@safe nothrow:

	this(const ref D3D12_DESCRIPTOR_RANGE o)
	{
		 m_D3D12_DESCRIPTOR_RANGE = o;
	}
	
	this(
		D3D12_DESCRIPTOR_RANGE_TYPE rangeType,
		UINT numDescriptors,
		UINT baseShaderRegister,
		UINT registerSpace = 0,
		UINT offsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND)
	{
		Init(rangeType, numDescriptors, baseShaderRegister, registerSpace, offsetInDescriptorsFromTableStart);
	}
	
	pragma(inline, true) void Init(
		D3D12_DESCRIPTOR_RANGE_TYPE rangeType,
		UINT numDescriptors,
		UINT baseShaderRegister,
		UINT registerSpace = 0,
		UINT offsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND)
	{
		Init(this, rangeType, numDescriptors, baseShaderRegister, registerSpace, offsetInDescriptorsFromTableStart);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_DESCRIPTOR_RANGE range, // _Out_
		D3D12_DESCRIPTOR_RANGE_TYPE rangeType,
		UINT numDescriptors,
		UINT baseShaderRegister,
		UINT registerSpace = 0,
		UINT offsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND)
	{
		range.RangeType = rangeType;
		range.NumDescriptors = numDescriptors;
		range.BaseShaderRegister = baseShaderRegister;
		range.RegisterSpace = registerSpace;
		range.OffsetInDescriptorsFromTableStart = offsetInDescriptorsFromTableStart;
	}
}

@safe nothrow unittest
{
	CD3DX12_DESCRIPTOR_RANGE testDescriptorRange = CD3DX12_DESCRIPTOR_RANGE();
	testDescriptorRange.Init(
		D3D12_DESCRIPTOR_RANGE_TYPE_SRV,
		UINT(0),
		UINT(0),
		UINT(0),
		D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND);
}

@safe nothrow unittest
{
	CD3DX12_DESCRIPTOR_RANGE testDescriptorRange = CD3DX12_DESCRIPTOR_RANGE();
	D3D12_DESCRIPTOR_RANGE outRange = D3D12_DESCRIPTOR_RANGE();
	testDescriptorRange.Init(
		outRange,
		D3D12_DESCRIPTOR_RANGE_TYPE_SRV,
		UINT(0),
		UINT(0),
		UINT(0),
		D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND);
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_DESCRIPTOR_TABLE
{
	D3D12_ROOT_DESCRIPTOR_TABLE m_D3D12_ROOT_DESCRIPTOR_TABLE;
	alias m_D3D12_ROOT_DESCRIPTOR_TABLE this;

	@safe nothrow:

	this(const ref D3D12_ROOT_DESCRIPTOR_TABLE o)
	{
		 m_D3D12_ROOT_DESCRIPTOR_TABLE = o;
	}
	
	this(
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE* _pDescriptorRanges) // _In_reads_opt_(numDescriptorRanges) 
	{
		Init(numDescriptorRanges, _pDescriptorRanges);
	}
	
	pragma(inline, true) void Init(
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE* _pDescriptorRanges) // _In_reads_opt_(numDescriptorRanges) 
	{
		Init(this, numDescriptorRanges, _pDescriptorRanges);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_ROOT_DESCRIPTOR_TABLE rootDescriptorTable, // _Out_
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE* _pDescriptorRanges) // _In_reads_opt_(numDescriptorRanges) 
	{
		rootDescriptorTable.NumDescriptorRanges = numDescriptorRanges;
		rootDescriptorTable.pDescriptorRanges = _pDescriptorRanges;
	}
}

@safe nothrow unittest
{
	CD3DX12_ROOT_DESCRIPTOR_TABLE testRootDescriptorTable = CD3DX12_ROOT_DESCRIPTOR_TABLE();
	testRootDescriptorTable.Init(UINT(0), null);
}

@safe nothrow unittest
{
	CD3DX12_ROOT_DESCRIPTOR_TABLE testRootDescriptorTable = CD3DX12_ROOT_DESCRIPTOR_TABLE();
	D3D12_ROOT_DESCRIPTOR_TABLE outRootDescriptorTable;
	testRootDescriptorTable.Init(outRootDescriptorTable, UINT(0), null);
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_CONSTANTS
{
	D3D12_ROOT_CONSTANTS m_D3D12_ROOT_CONSTANTS;
	alias m_D3D12_ROOT_CONSTANTS this;

	@safe nothrow:

	this(const ref D3D12_ROOT_CONSTANTS o)
	{
		 m_D3D12_ROOT_CONSTANTS = o;
	}
	
	this(
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0)
	{
		Init(num32BitValues, shaderRegister, registerSpace);
	}
	
	pragma(inline, true) void Init(
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0)
	{
		Init(this, num32BitValues, shaderRegister, registerSpace);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_ROOT_CONSTANTS rootConstants, // _Out_
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0)
	{
		rootConstants.Num32BitValues = num32BitValues;
		rootConstants.ShaderRegister = shaderRegister;
		rootConstants.RegisterSpace = registerSpace;
	}
}

@safe nothrow unittest
{
	CD3DX12_ROOT_CONSTANTS testRootConstants = CD3DX12_ROOT_CONSTANTS();
	testRootConstants.Init(UINT(0), UINT(0), UINT(0));
}

@safe nothrow unittest
{
	CD3DX12_ROOT_CONSTANTS testRootConstants = CD3DX12_ROOT_CONSTANTS();
	D3D12_ROOT_CONSTANTS outRootConstants;
	testRootConstants.Init(outRootConstants, UINT(0), UINT(0), UINT(0));
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_DESCRIPTOR
{
	D3D12_ROOT_DESCRIPTOR m_D3D12_ROOT_DESCRIPTOR;
	alias m_D3D12_ROOT_DESCRIPTOR this;

	@safe nothrow:

	this(const ref D3D12_ROOT_DESCRIPTOR o)
	{
		 m_D3D12_ROOT_DESCRIPTOR = o;
	}
	
	this(
		UINT shaderRegister,
		UINT registerSpace = 0)
	{
		Init(shaderRegister, registerSpace);
	}
	
	pragma(inline, true) void Init(
		UINT shaderRegister,
		UINT registerSpace = 0)
	{
		Init(this, shaderRegister, registerSpace);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_ROOT_DESCRIPTOR table, // _Out_
		UINT shaderRegister, 
		UINT registerSpace = 0)
	{
		table.ShaderRegister = shaderRegister;
		table.RegisterSpace = registerSpace;
	}
}

@safe nothrow unittest
{
	CD3DX12_ROOT_DESCRIPTOR testRootDescriptor = CD3DX12_ROOT_DESCRIPTOR();
	testRootDescriptor.Init(UINT(0), UINT(0));
}

@safe nothrow unittest
{
	CD3DX12_ROOT_DESCRIPTOR testRootDescriptor = CD3DX12_ROOT_DESCRIPTOR();
	D3D12_ROOT_DESCRIPTOR outRootDescriptor;
	testRootDescriptor.Init(outRootDescriptor, UINT(0), UINT(0));
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_PARAMETER
{
	D3D12_ROOT_PARAMETER m_D3D12_ROOT_PARAMETER;
	alias m_D3D12_ROOT_PARAMETER this;
	
	this(const ref D3D12_ROOT_PARAMETER o) @safe nothrow
	{
		 m_D3D12_ROOT_PARAMETER = o;
	}
	
	static pragma(inline, true) void InitAsDescriptorTable(
		ref D3D12_ROOT_PARAMETER rootParam, // _Out_
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE* pDescriptorRanges, // _In_reads_(numDescriptorRanges) 
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR_TABLE.Init(rootParam.DescriptorTable, numDescriptorRanges, pDescriptorRanges);
	}

	static pragma(inline, true) void InitAsConstants(
		ref D3D12_ROOT_PARAMETER rootParam, // _Out_
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_CONSTANTS.Init(rootParam.Constants, num32BitValues, shaderRegister, registerSpace);
	}

	static pragma(inline, true) void InitAsConstantBufferView(
		ref D3D12_ROOT_PARAMETER rootParam, // _Out_
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR.Init(rootParam.Descriptor, shaderRegister, registerSpace);
	}

	static pragma(inline, true) void InitAsShaderResourceView(
		ref D3D12_ROOT_PARAMETER rootParam, // _Out_
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR.Init(rootParam.Descriptor, shaderRegister, registerSpace);
	}

	static pragma(inline, true) void InitAsUnorderedAccessView(
		ref D3D12_ROOT_PARAMETER rootParam, // _Out_
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR.Init(rootParam.Descriptor, shaderRegister, registerSpace);
	}
	
	pragma(inline, true) void InitAsDescriptorTable(
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE* pDescriptorRanges, // _In_reads_(numDescriptorRanges) 
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		InitAsDescriptorTable(this, numDescriptorRanges, pDescriptorRanges, visibility);
	}
	
	pragma(inline, true) void InitAsConstants(
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		InitAsConstants(this, num32BitValues, shaderRegister, registerSpace, visibility);
	}

	pragma(inline, true) void InitAsConstantBufferView(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		InitAsConstantBufferView(this, shaderRegister, registerSpace, visibility);
	}

	pragma(inline, true) void InitAsShaderResourceView(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		InitAsShaderResourceView(this, shaderRegister, registerSpace, visibility);
	}

	pragma(inline, true) void InitAsUnorderedAccessView(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL) nothrow
	{
		InitAsUnorderedAccessView(this, shaderRegister, registerSpace, visibility);
	}
}

nothrow unittest
{
	CD3DX12_ROOT_PARAMETER testRootParameter = CD3DX12_ROOT_PARAMETER();
	
	UINT numDescriptorRanges = 0;
	UINT num32BitValues = 0;
	UINT shaderRegister = 0;
	UINT registerSpace = 0;
	const D3D12_DESCRIPTOR_RANGE* pDescriptorRanges = null;
	D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL;

	testRootParameter.InitAsDescriptorTable(
		numDescriptorRanges,
		pDescriptorRanges,
		visibility);

	testRootParameter.InitAsConstants(
		num32BitValues,
		shaderRegister,
		registerSpace,
		visibility);

	testRootParameter.InitAsConstantBufferView(
		shaderRegister,
		registerSpace,
		visibility);

	testRootParameter.InitAsShaderResourceView(
		shaderRegister,
		registerSpace,
		visibility);

	testRootParameter.InitAsUnorderedAccessView(
		shaderRegister,
		registerSpace,
		visibility);
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_STATIC_SAMPLER_DESC
{
	D3D12_STATIC_SAMPLER_DESC m_D3D12_STATIC_SAMPLER_DESC;
	alias m_D3D12_STATIC_SAMPLER_DESC this;

	@safe nothrow:

	this(const ref D3D12_STATIC_SAMPLER_DESC o)
	{
		 m_D3D12_STATIC_SAMPLER_DESC = o;
	}

	this(
		 UINT shaderRegister,
		 D3D12_FILTER filter = D3D12_FILTER_ANISOTROPIC,
		 D3D12_TEXTURE_ADDRESS_MODE addressU = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		 D3D12_TEXTURE_ADDRESS_MODE addressV = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		 D3D12_TEXTURE_ADDRESS_MODE addressW = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		 FLOAT mipLODBias = 0,
		 UINT maxAnisotropy = 16,
		 D3D12_COMPARISON_FUNC comparisonFunc = D3D12_COMPARISON_FUNC_LESS_EQUAL,
		 D3D12_STATIC_BORDER_COLOR borderColor = D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE,
		 FLOAT minLOD = 0.0f,
		 FLOAT maxLOD = D3D12_FLOAT32_MAX,
		 D3D12_SHADER_VISIBILITY shaderVisibility = D3D12_SHADER_VISIBILITY_ALL, 
		 UINT registerSpace = 0)
	{
		Init(
			shaderRegister,
			filter,
			addressU,
			addressV,
			addressW,
			mipLODBias,
			maxAnisotropy,
			comparisonFunc,
			borderColor,
			minLOD,
			maxLOD,
			shaderVisibility,
			registerSpace);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_STATIC_SAMPLER_DESC samplerDesc,	// _Out_
		UINT shaderRegister,
		D3D12_FILTER filter = D3D12_FILTER_ANISOTROPIC,
		D3D12_TEXTURE_ADDRESS_MODE addressU = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		D3D12_TEXTURE_ADDRESS_MODE addressV = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		D3D12_TEXTURE_ADDRESS_MODE addressW = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		FLOAT mipLODBias = 0,
		UINT maxAnisotropy = 16,
		D3D12_COMPARISON_FUNC comparisonFunc = D3D12_COMPARISON_FUNC_LESS_EQUAL,
		D3D12_STATIC_BORDER_COLOR borderColor = D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE,
		FLOAT minLOD = 0.0f,
		FLOAT maxLOD = D3D12_FLOAT32_MAX,
		D3D12_SHADER_VISIBILITY shaderVisibility = D3D12_SHADER_VISIBILITY_ALL, 
		UINT registerSpace = 0)
	{
		samplerDesc.ShaderRegister = shaderRegister;
		samplerDesc.Filter = filter;
		samplerDesc.AddressU = addressU;
		samplerDesc.AddressV = addressV;
		samplerDesc.AddressW = addressW;
		samplerDesc.MipLODBias = mipLODBias;
		samplerDesc.MaxAnisotropy = maxAnisotropy;
		samplerDesc.ComparisonFunc = comparisonFunc;
		samplerDesc.BorderColor = borderColor;
		samplerDesc.MinLOD = minLOD;
		samplerDesc.MaxLOD = maxLOD;
		samplerDesc.ShaderVisibility = shaderVisibility;
		samplerDesc.RegisterSpace = registerSpace;
	}
	pragma(inline, true) void Init(
		 UINT shaderRegister,
		 D3D12_FILTER filter = D3D12_FILTER_ANISOTROPIC,
		 D3D12_TEXTURE_ADDRESS_MODE addressU = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		 D3D12_TEXTURE_ADDRESS_MODE addressV = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		 D3D12_TEXTURE_ADDRESS_MODE addressW = D3D12_TEXTURE_ADDRESS_MODE_WRAP,
		 FLOAT mipLODBias = 0,
		 UINT maxAnisotropy = 16,
		 D3D12_COMPARISON_FUNC comparisonFunc = D3D12_COMPARISON_FUNC_LESS_EQUAL,
		 D3D12_STATIC_BORDER_COLOR borderColor = D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE,
		 FLOAT minLOD = 0.0f,
		 FLOAT maxLOD = D3D12_FLOAT32_MAX,
		 D3D12_SHADER_VISIBILITY shaderVisibility = D3D12_SHADER_VISIBILITY_ALL, 
		 UINT registerSpace = 0)
	{
		Init(
			this,
			shaderRegister,
			filter,
			addressU,
			addressV,
			addressW,
			mipLODBias,
			maxAnisotropy,
			comparisonFunc,
			borderColor,
			minLOD,
			maxLOD,
			shaderVisibility,
			registerSpace);
	}   
}

@safe nothrow unittest
{
	immutable UINT shaderRegister = 0;
	immutable CD3DX12_STATIC_SAMPLER_DESC testStaticSamplerDesc = CD3DX12_STATIC_SAMPLER_DESC(shaderRegister);
	cast(void)(testStaticSamplerDesc); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_SIGNATURE_DESC
{
	D3D12_ROOT_SIGNATURE_DESC m_D3D12_ROOT_SIGNATURE_DESC;
	alias m_D3D12_ROOT_SIGNATURE_DESC this;

	@safe nothrow:

	this(const ref D3D12_ROOT_SIGNATURE_DESC o)
	{
		 m_D3D12_ROOT_SIGNATURE_DESC = o;
	}
	
	this(
		UINT numParameters,
		const D3D12_ROOT_PARAMETER* _pParameters, // _In_reads_opt_(numParameters) 
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null, // _In_reads_opt_(numStaticSamplers) 
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		Init(numParameters, _pParameters, numStaticSamplers, _pStaticSamplers, flags);
	}
	
	this(CD3DX12_DEFAULT)
	{
		Init(0, null, 0, null, D3D12_ROOT_SIGNATURE_FLAG_NONE);
	}
	
	pragma(inline, true) void Init(
		UINT numParameters,
		const D3D12_ROOT_PARAMETER* _pParameters, // _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null, // _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		Init(this, numParameters, _pParameters, numStaticSamplers, _pStaticSamplers, flags);
	}

	static pragma(inline, true) void Init(
		ref D3D12_ROOT_SIGNATURE_DESC desc, // _Out_
		UINT numParameters,
		const D3D12_ROOT_PARAMETER* _pParameters, // _In_reads_opt_(numParameters) 
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null, // _In_reads_opt_(numStaticSamplers) 
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		desc.NumParameters = numParameters;
		desc.pParameters = _pParameters;
		desc.NumStaticSamplers = numStaticSamplers;
		desc.pStaticSamplers = _pStaticSamplers;
		desc.Flags = flags;
	}

	D3D12_ROOT_SIGNATURE_DESC * ptr() { return &m_D3D12_ROOT_SIGNATURE_DESC; }
}

@safe nothrow unittest
{
	const CD3DX12_ROOT_SIGNATURE_DESC testRootSignatureDesc = const CD3DX12_ROOT_SIGNATURE_DESC(D3D12_DEFAULT);
	cast(void)(testRootSignatureDesc); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_DESCRIPTOR_RANGE1
{
	D3D12_DESCRIPTOR_RANGE1 m_D3D12_DESCRIPTOR_RANGE1;
	alias m_D3D12_DESCRIPTOR_RANGE1 this;

	@safe nothrow:

	this(const ref D3D12_DESCRIPTOR_RANGE1 o)
	{
		 m_D3D12_DESCRIPTOR_RANGE1 = o;
	}

	this(
		D3D12_DESCRIPTOR_RANGE_TYPE rangeType,
		UINT numDescriptors,
		UINT baseShaderRegister,
		UINT registerSpace = 0,
		D3D12_DESCRIPTOR_RANGE_FLAGS flags = D3D12_DESCRIPTOR_RANGE_FLAG_NONE,
		UINT offsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND)
	{
		Init(rangeType, numDescriptors, baseShaderRegister, registerSpace, flags, offsetInDescriptorsFromTableStart);
	}
	
	pragma(inline, true) void Init(
		D3D12_DESCRIPTOR_RANGE_TYPE rangeType,
		UINT numDescriptors,
		UINT baseShaderRegister,
		UINT registerSpace = 0,
		D3D12_DESCRIPTOR_RANGE_FLAGS flags = D3D12_DESCRIPTOR_RANGE_FLAG_NONE,
		UINT offsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND)
	{
		Init(this, rangeType, numDescriptors, baseShaderRegister, registerSpace, flags, offsetInDescriptorsFromTableStart);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_DESCRIPTOR_RANGE1 range, // _Out_
		D3D12_DESCRIPTOR_RANGE_TYPE rangeType,
		UINT numDescriptors,
		UINT baseShaderRegister,
		UINT registerSpace = 0,
		D3D12_DESCRIPTOR_RANGE_FLAGS flags = D3D12_DESCRIPTOR_RANGE_FLAG_NONE,
		UINT offsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND)
	{
		range.RangeType = rangeType;
		range.NumDescriptors = numDescriptors;
		range.BaseShaderRegister = baseShaderRegister;
		range.RegisterSpace = registerSpace;
		range.Flags = flags;
		range.OffsetInDescriptorsFromTableStart = offsetInDescriptorsFromTableStart;
	}
}

@safe nothrow unittest
{
	immutable CD3DX12_DESCRIPTOR_RANGE1 testDescriptorRange1 = CD3DX12_DESCRIPTOR_RANGE1(D3D12_DESCRIPTOR_RANGE_TYPE_SRV, UINT(0), UINT(0));
	cast(void)(testDescriptorRange1); // unused
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_DESCRIPTOR_TABLE1
{
	D3D12_ROOT_DESCRIPTOR_TABLE1 m_D3D12_ROOT_DESCRIPTOR_TABLE1;
	alias m_D3D12_ROOT_DESCRIPTOR_TABLE1 this;

	this(const ref D3D12_ROOT_DESCRIPTOR_TABLE1 o) nothrow
	{
		// Error: cannot implicitly convert expression o of type const(D3D12_RESOURCE_BARRIER) to D3D12_RESOURCE_BARRIER
		// My guess is that this is because D3D12_RESOURCE_BARRIER contains a union.
		 m_D3D12_ROOT_DESCRIPTOR_TABLE1 = cast(D3D12_ROOT_DESCRIPTOR_TABLE1)(o);
	}

	nothrow:

	this(
		UINT numDescriptorRanges,
		const(D3D12_DESCRIPTOR_RANGE1)* _pDescriptorRanges) // _In_reads_opt_(numDescriptorRanges) 
	{
		Init(numDescriptorRanges, _pDescriptorRanges);
	}
	
	pragma(inline, true) void Init(
		UINT numDescriptorRanges,
		const(D3D12_DESCRIPTOR_RANGE1)* _pDescriptorRanges) // _In_reads_opt_(numDescriptorRanges) 
	{
		Init(this, numDescriptorRanges, _pDescriptorRanges);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_ROOT_DESCRIPTOR_TABLE1 rootDescriptorTable,	// _Out_
		UINT numDescriptorRanges,
		const(D3D12_DESCRIPTOR_RANGE1)* _pDescriptorRanges) // _In_reads_opt_(numDescriptorRanges) 
	{
		rootDescriptorTable.NumDescriptorRanges = numDescriptorRanges;
		rootDescriptorTable.pDescriptorRanges = _pDescriptorRanges;
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_DESCRIPTOR1
{
	D3D12_ROOT_DESCRIPTOR1 m_D3D12_ROOT_DESCRIPTOR1;
	alias m_D3D12_ROOT_DESCRIPTOR1 this;

	@safe nothrow:

	this(const ref D3D12_ROOT_DESCRIPTOR1 o)
	{
		 m_D3D12_ROOT_DESCRIPTOR1 = o;
	}

	this(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE)
	{
		Init(shaderRegister, registerSpace, flags);
	}
	
	pragma(inline, true) void Init(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE)
	{
		Init(this, shaderRegister, registerSpace, flags);
	}
	
	static pragma(inline, true) void Init(
		ref D3D12_ROOT_DESCRIPTOR1 table,	// _Out_ 
		UINT shaderRegister, 
		UINT registerSpace = 0, 
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE)
	{
		table.ShaderRegister = shaderRegister;
		table.RegisterSpace = registerSpace;
		table.Flags = flags;
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_ROOT_PARAMETER1
{
	D3D12_ROOT_PARAMETER1 m_D3D12_ROOT_PARAMETER1;
	alias m_D3D12_ROOT_PARAMETER1 this;

	this(const ref D3D12_ROOT_PARAMETER1 o) @safe nothrow
	{
		 m_D3D12_ROOT_PARAMETER1 = o;
	}
	
	nothrow:
	
	static pragma(inline, true) void InitAsDescriptorTable(
		ref D3D12_ROOT_PARAMETER1 rootParam,	// _Out_
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE1* pDescriptorRanges,	// _In_reads_(numDescriptorRanges) 
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR_TABLE1.Init(rootParam.DescriptorTable, numDescriptorRanges, pDescriptorRanges);
	}

	static pragma(inline, true) void InitAsConstants(
		ref D3D12_ROOT_PARAMETER1 rootParam,	// _Out_
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_CONSTANTS.Init(rootParam.Constants, num32BitValues, shaderRegister, registerSpace);
	}

	static pragma(inline, true) void InitAsConstantBufferView(
		ref D3D12_ROOT_PARAMETER1 rootParam,	// _Out_
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_CBV;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR1.Init(rootParam.Descriptor, shaderRegister, registerSpace, flags);
	}

	static pragma(inline, true) void InitAsShaderResourceView(
		ref D3D12_ROOT_PARAMETER1 rootParam,	// _Out_
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_SRV;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR1.Init(rootParam.Descriptor, shaderRegister, registerSpace, flags);
	}

	static pragma(inline, true) void InitAsUnorderedAccessView(
		ref D3D12_ROOT_PARAMETER1 rootParam,	// _Out_
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		rootParam.ParameterType = D3D12_ROOT_PARAMETER_TYPE_UAV;
		rootParam.ShaderVisibility = visibility;
		CD3DX12_ROOT_DESCRIPTOR1.Init(rootParam.Descriptor, shaderRegister, registerSpace, flags);
	}
	
	pragma(inline, true) void InitAsDescriptorTable(
		UINT numDescriptorRanges,
		const D3D12_DESCRIPTOR_RANGE1* pDescriptorRanges,	// _In_reads_(numDescriptorRanges) 
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		InitAsDescriptorTable(this, numDescriptorRanges, pDescriptorRanges, visibility);
	}
	
	pragma(inline, true) void InitAsConstants(
		UINT num32BitValues,
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		InitAsConstants(this, num32BitValues, shaderRegister, registerSpace, visibility);
	}

	pragma(inline, true) void InitAsConstantBufferView(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		InitAsConstantBufferView(this, shaderRegister, registerSpace, flags, visibility);
	}

	pragma(inline, true) void InitAsShaderResourceView(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		InitAsShaderResourceView(this, shaderRegister, registerSpace, flags, visibility);
	}

	pragma(inline, true) void InitAsUnorderedAccessView(
		UINT shaderRegister,
		UINT registerSpace = 0,
		D3D12_ROOT_DESCRIPTOR_FLAGS flags = D3D12_ROOT_DESCRIPTOR_FLAG_NONE,
		D3D12_SHADER_VISIBILITY visibility = D3D12_SHADER_VISIBILITY_ALL)
	{
		InitAsUnorderedAccessView(this, shaderRegister, registerSpace, flags, visibility);
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_VERSIONED_ROOT_SIGNATURE_DESC
{
	D3D12_VERSIONED_ROOT_SIGNATURE_DESC m_D3D12_VERSIONED_ROOT_SIGNATURE_DESC;
	alias m_D3D12_VERSIONED_ROOT_SIGNATURE_DESC this;

	nothrow:

	this(const ref D3D12_VERSIONED_ROOT_SIGNATURE_DESC o)
	{
		 m_D3D12_VERSIONED_ROOT_SIGNATURE_DESC = o;
	}
	
	this(const ref D3D12_ROOT_SIGNATURE_DESC o)
	{
		Version = D3D_ROOT_SIGNATURE_VERSION_1_0;
		Desc_1_0 = o;
	}
	
	this(const ref D3D12_ROOT_SIGNATURE_DESC1 o)
	{
		Version = D3D_ROOT_SIGNATURE_VERSION_1_1;
		Desc_1_1 = o;
	}
	
	this(
		UINT numParameters,
		const D3D12_ROOT_PARAMETER* _pParameters,	// _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null,	// _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		Init_1_0(numParameters, _pParameters, numStaticSamplers, _pStaticSamplers, flags);
	}
	
	this(
		UINT numParameters,
		const D3D12_ROOT_PARAMETER1* _pParameters,	// _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null,	// _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		Init_1_1(numParameters, _pParameters, numStaticSamplers, _pStaticSamplers, flags);
	}
	
	this(CD3DX12_DEFAULT)
	{
		Init_1_1(0, null, 0, null, D3D12_ROOT_SIGNATURE_FLAG_NONE);
	}
	
	pragma(inline, true) void Init_1_0(
		UINT numParameters,
		const D3D12_ROOT_PARAMETER* _pParameters,	// _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null,	// _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		Init_1_0(this, numParameters, _pParameters, numStaticSamplers, _pStaticSamplers, flags);
	}

	static pragma(inline, true) void Init_1_0(
		ref D3D12_VERSIONED_ROOT_SIGNATURE_DESC desc,	// _Out_
		UINT numParameters,
		const D3D12_ROOT_PARAMETER* _pParameters,	// _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null,	// _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		desc.Version = D3D_ROOT_SIGNATURE_VERSION_1_0;
		desc.Desc_1_0.NumParameters = numParameters;
		desc.Desc_1_0.pParameters = _pParameters;
		desc.Desc_1_0.NumStaticSamplers = numStaticSamplers;
		desc.Desc_1_0.pStaticSamplers = _pStaticSamplers;
		desc.Desc_1_0.Flags = flags;
	}

	pragma(inline, true) void Init_1_1(
		UINT numParameters,
		const D3D12_ROOT_PARAMETER1* _pParameters,	// _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null,	// _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		Init_1_1(this, numParameters, _pParameters, numStaticSamplers, _pStaticSamplers, flags);
	}

	static pragma(inline, true) void Init_1_1(
		ref D3D12_VERSIONED_ROOT_SIGNATURE_DESC desc,	// _Out_
		UINT numParameters,
		const D3D12_ROOT_PARAMETER1* _pParameters,	// _In_reads_opt_(numParameters)
		UINT numStaticSamplers = 0,
		const D3D12_STATIC_SAMPLER_DESC* _pStaticSamplers = null,	// _In_reads_opt_(numStaticSamplers)
		D3D12_ROOT_SIGNATURE_FLAGS flags = D3D12_ROOT_SIGNATURE_FLAG_NONE)
	{
		desc.Version = D3D_ROOT_SIGNATURE_VERSION_1_1;
		desc.Desc_1_1.NumParameters = numParameters;
		desc.Desc_1_1.pParameters = _pParameters;
		desc.Desc_1_1.NumStaticSamplers = numStaticSamplers;
		desc.Desc_1_1.pStaticSamplers = _pStaticSamplers;
		desc.Desc_1_1.Flags = flags;
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_CPU_DESCRIPTOR_HANDLE
{
	D3D12_CPU_DESCRIPTOR_HANDLE m_D3D12_CPU_DESCRIPTOR_HANDLE;
	alias m_D3D12_CPU_DESCRIPTOR_HANDLE this;

	@safe nothrow:

	this(const ref D3D12_CPU_DESCRIPTOR_HANDLE o)
	{
		 m_D3D12_CPU_DESCRIPTOR_HANDLE = o;
	}
	
	this(CD3DX12_DEFAULT) { ptr = 0; }
	
	this(
		const ref D3D12_CPU_DESCRIPTOR_HANDLE other,	// _In_ 
		INT offsetScaledByIncrementSize)
	{
		InitOffsetted(other, offsetScaledByIncrementSize);
	}
	
	this(
		const ref D3D12_CPU_DESCRIPTOR_HANDLE other,	// _In_ 
		INT offsetInDescriptors, 
		UINT descriptorIncrementSize)
	{
		InitOffsetted(other, offsetInDescriptors, descriptorIncrementSize);
	}

	ref CD3DX12_CPU_DESCRIPTOR_HANDLE Offset(INT offsetInDescriptors, UINT descriptorIncrementSize)
	{ 
		ptr += offsetInDescriptors * descriptorIncrementSize;
		return this;
	}

	ref CD3DX12_CPU_DESCRIPTOR_HANDLE Offset(INT offsetScaledByIncrementSize) 
	{ 
		ptr += offsetScaledByIncrementSize;
		return this;
	}

	ulong toHash() const nothrow @safe pure
	{
		return hashOf(this);
	}

	bool opEquals(const ref D3D12_CPU_DESCRIPTOR_HANDLE other) const // _In_
	{
		return (ptr == other.ptr);
	}

	// already handled by opEquals();
	//bool operator!=(_In_ const ref D3D12_CPU_DESCRIPTOR_HANDLE other) const
	//{
	//	return (ptr != other.ptr);
	//}

	ref CD3DX12_CPU_DESCRIPTOR_HANDLE opAssign(const ref D3D12_CPU_DESCRIPTOR_HANDLE other)
	{
		ptr = other.ptr;
		return this;
	}
	
	pragma(inline, true) void InitOffsetted(
		const ref D3D12_CPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetScaledByIncrementSize)
	{
		InitOffsetted(this, base, offsetScaledByIncrementSize);
	}
	
	pragma(inline, true) void InitOffsetted(
		const ref D3D12_CPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetInDescriptors, 
		UINT descriptorIncrementSize)
	{
		InitOffsetted(this, base, offsetInDescriptors, descriptorIncrementSize);
	}
	
	static pragma(inline, true) void InitOffsetted(
		ref D3D12_CPU_DESCRIPTOR_HANDLE handle,	// _Out_ 
		const ref D3D12_CPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetScaledByIncrementSize)
	{
		handle.ptr = base.ptr + offsetScaledByIncrementSize;
	}
	
	static pragma(inline, true) void InitOffsetted(
		ref D3D12_CPU_DESCRIPTOR_HANDLE handle,	// _Out_ 
		const ref D3D12_CPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetInDescriptors, 
		UINT descriptorIncrementSize)
	{
		handle.ptr = base.ptr + offsetInDescriptors * descriptorIncrementSize;
	}
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_GPU_DESCRIPTOR_HANDLE
{
	D3D12_GPU_DESCRIPTOR_HANDLE m_D3D12_GPU_DESCRIPTOR_HANDLE;
	alias m_D3D12_GPU_DESCRIPTOR_HANDLE this;

	@safe nothrow:

	this(const ref D3D12_GPU_DESCRIPTOR_HANDLE o)
	{
		 m_D3D12_GPU_DESCRIPTOR_HANDLE = o;
	}
	
	this(CD3DX12_DEFAULT) { ptr = 0; }
	
	this(
		const ref D3D12_GPU_DESCRIPTOR_HANDLE other,	// _In_ 
		INT offsetScaledByIncrementSize)
	{
		InitOffsetted(other, offsetScaledByIncrementSize);
	}
	
	this(
		const ref D3D12_GPU_DESCRIPTOR_HANDLE other,	// _In_ 
		INT offsetInDescriptors, 
		UINT descriptorIncrementSize)
	{
		InitOffsetted(other, offsetInDescriptors, descriptorIncrementSize);
	}

	ref CD3DX12_GPU_DESCRIPTOR_HANDLE Offset(INT offsetInDescriptors, UINT descriptorIncrementSize)
	{ 
		ptr += offsetInDescriptors * descriptorIncrementSize;
		return this;
	}

	ref CD3DX12_GPU_DESCRIPTOR_HANDLE Offset(INT offsetScaledByIncrementSize) 
	{ 
		ptr += offsetScaledByIncrementSize;
		return this;
	}

	ulong toHash() const nothrow @safe pure
	{
		return hashOf(this);
	}
	
	pragma(inline, true) bool opEquals(const ref D3D12_GPU_DESCRIPTOR_HANDLE other) const // _In_
	{
		return (ptr == other.ptr);
	}

	//pragma(inline, true) bool operator!=(const ref D3D12_GPU_DESCRIPTOR_HANDLE other) const // _In_
	//{
	//	return (ptr != other.ptr);
	//}

	ref CD3DX12_GPU_DESCRIPTOR_HANDLE opAssign(const ref D3D12_GPU_DESCRIPTOR_HANDLE other)
	{
		ptr = other.ptr;
		return this;
	}
	
	pragma(inline, true) void InitOffsetted(
		const ref D3D12_GPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetScaledByIncrementSize)
	{
		InitOffsetted(this, base, offsetScaledByIncrementSize);
	}
	
	pragma(inline, true) void InitOffsetted(
		const ref D3D12_GPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetInDescriptors, 
		UINT descriptorIncrementSize)
	{
		InitOffsetted(this, base, offsetInDescriptors, descriptorIncrementSize);
	}
	
	static pragma(inline, true) void InitOffsetted(
		ref D3D12_GPU_DESCRIPTOR_HANDLE handle,	// _Out_ 
		const ref D3D12_GPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetScaledByIncrementSize)
	{
		handle.ptr = base.ptr + offsetScaledByIncrementSize;
	}
	
	static pragma(inline, true) void InitOffsetted(
		ref D3D12_GPU_DESCRIPTOR_HANDLE handle,	// _Out_ 
		const ref D3D12_GPU_DESCRIPTOR_HANDLE base,	// _In_ 
		INT offsetInDescriptors, 
		UINT descriptorIncrementSize)
	{
		handle.ptr = base.ptr + offsetInDescriptors * descriptorIncrementSize;
	}
}

//------------------------------------------------------------------------------------------------
pragma(inline, true) UINT D3D12CalcSubresource( UINT MipSlice, UINT ArraySlice, UINT PlaneSlice, UINT MipLevels, UINT ArraySize ) @safe nothrow
{ 
	return MipSlice + ArraySlice * MipLevels + PlaneSlice * MipLevels * ArraySize; 
}

//------------------------------------------------------------------------------------------------
//template <typename T, typename U, typename V>
pragma(inline, true) void D3D12DecomposeSubresource(T, U, V)( 
	UINT Subresource, 
	UINT MipLevels, 
	UINT ArraySize, 
	ref T MipSlice,	// _Out_ 
	ref U ArraySlice,	// _Out_ 
	ref V PlaneSlice) // _Out_
{
	MipSlice = cast(T)(Subresource % MipLevels);
	ArraySlice = cast(U)((Subresource / MipLevels) % ArraySize);
	PlaneSlice = cast(V)(Subresource / (MipLevels * ArraySize));
}

//------------------------------------------------------------------------------------------------
pragma(inline, true) UINT8 D3D12GetFormatPlaneCount(
	ID3D12Device* pDevice, // _In_
	DXGI_FORMAT Format)
{
	D3D12_FEATURE_DATA_FORMAT_INFO formatInfo = {Format};
	if (FAILED(pDevice.CheckFeatureSupport(D3D12_FEATURE_FORMAT_INFO, &formatInfo, formatInfo.sizeof)))
	{
		return 0;
	}
	return formatInfo.PlaneCount;
}

//------------------------------------------------------------------------------------------------
struct CD3DX12_RESOURCE_DESC
{
	D3D12_RESOURCE_DESC m_D3D12_RESOURCE_DESC;
	alias m_D3D12_RESOURCE_DESC this;

	

	this(const ref D3D12_RESOURCE_DESC o) @safe nothrow
	{
		 m_D3D12_RESOURCE_DESC = o;
	}
	
	this( 
		D3D12_RESOURCE_DIMENSION dimension,
		UINT64 alignment,
		UINT64 width,
		UINT height,
		UINT16 depthOrArraySize,
		UINT16 mipLevels,
		DXGI_FORMAT format,
		UINT sampleCount,
		UINT sampleQuality,
		D3D12_TEXTURE_LAYOUT layout,
		D3D12_RESOURCE_FLAGS flags ) @safe nothrow
	{
		Dimension = dimension;
		Alignment = alignment;
		Width = width;
		Height = height;
		DepthOrArraySize = depthOrArraySize;
		MipLevels = mipLevels;
		Format = format;
		SampleDesc.Count = sampleCount;
		SampleDesc.Quality = sampleQuality;
		Layout = layout;
		Flags = flags;
	}
	static pragma(inline, true) CD3DX12_RESOURCE_DESC Buffer( 
		const ref D3D12_RESOURCE_ALLOCATION_INFO resAllocInfo,
		D3D12_RESOURCE_FLAGS flags = D3D12_RESOURCE_FLAG_NONE ) @safe nothrow
	{
		return CD3DX12_RESOURCE_DESC( D3D12_RESOURCE_DIMENSION_BUFFER, resAllocInfo.Alignment, resAllocInfo.SizeInBytes, 
			1, 1, 1, DXGI_FORMAT_UNKNOWN, 1, 0, D3D12_TEXTURE_LAYOUT_ROW_MAJOR, flags );
	}
	static pragma(inline, true) CD3DX12_RESOURCE_DESC Buffer( 
		UINT64 width,
		D3D12_RESOURCE_FLAGS flags = D3D12_RESOURCE_FLAG_NONE,
		UINT64 alignment = 0 ) @safe nothrow
	{
		return CD3DX12_RESOURCE_DESC( D3D12_RESOURCE_DIMENSION_BUFFER, alignment, width, 1, 1, 1, 
			DXGI_FORMAT_UNKNOWN, 1, 0, D3D12_TEXTURE_LAYOUT_ROW_MAJOR, flags );
	}
	static pragma(inline, true) CD3DX12_RESOURCE_DESC Tex1D( 
		DXGI_FORMAT format,
		UINT64 width,
		UINT16 arraySize = 1,
		UINT16 mipLevels = 0,
		D3D12_RESOURCE_FLAGS flags = D3D12_RESOURCE_FLAG_NONE,
		D3D12_TEXTURE_LAYOUT layout = D3D12_TEXTURE_LAYOUT_UNKNOWN,
		UINT64 alignment = 0 ) @safe nothrow
	{
		return CD3DX12_RESOURCE_DESC( D3D12_RESOURCE_DIMENSION_TEXTURE1D, alignment, width, 1, arraySize, 
			mipLevels, format, 1, 0, layout, flags );
	}
	static pragma(inline, true) CD3DX12_RESOURCE_DESC Tex2D( 
		DXGI_FORMAT format,
		UINT64 width,
		UINT height,
		UINT16 arraySize = 1,
		UINT16 mipLevels = 0,
		UINT sampleCount = 1,
		UINT sampleQuality = 0,
		D3D12_RESOURCE_FLAGS flags = D3D12_RESOURCE_FLAG_NONE,
		D3D12_TEXTURE_LAYOUT layout = D3D12_TEXTURE_LAYOUT_UNKNOWN,
		UINT64 alignment = 0 ) @safe nothrow
	{
		return CD3DX12_RESOURCE_DESC( D3D12_RESOURCE_DIMENSION_TEXTURE2D, alignment, width, height, arraySize, 
			mipLevels, format, sampleCount, sampleQuality, layout, flags );
	}
	static pragma(inline, true) CD3DX12_RESOURCE_DESC Tex3D( 
		DXGI_FORMAT format,
		UINT64 width,
		UINT height,
		UINT16 depth,
		UINT16 mipLevels = 0,
		D3D12_RESOURCE_FLAGS flags = D3D12_RESOURCE_FLAG_NONE,
		D3D12_TEXTURE_LAYOUT layout = D3D12_TEXTURE_LAYOUT_UNKNOWN,
		UINT64 alignment = 0 ) @safe nothrow
	{
		return CD3DX12_RESOURCE_DESC( D3D12_RESOURCE_DIMENSION_TEXTURE3D, alignment, width, height, depth, 
			mipLevels, format, 1, 0, layout, flags );
	}
	pragma(inline, true) UINT16 Depth() const @safe nothrow
	{ return (Dimension == D3D12_RESOURCE_DIMENSION_TEXTURE3D ? DepthOrArraySize : 1); }
	pragma(inline, true) UINT16 ArraySize() const @safe nothrow
	{ return (Dimension != D3D12_RESOURCE_DIMENSION_TEXTURE3D ? DepthOrArraySize : 1); }
	pragma(inline, true) UINT8 PlaneCount(ID3D12Device* pDevice) const // _In_
	{ return D3D12GetFormatPlaneCount(pDevice, Format); }
	pragma(inline, true) UINT Subresources(ID3D12Device* pDevice) const // _In_
	{ return MipLevels * ArraySize() * PlaneCount(pDevice); }
	pragma(inline, true) UINT CalcSubresource(UINT MipSlice, UINT ArraySlice, UINT PlaneSlice) @safe nothrow
	{ return D3D12CalcSubresource(MipSlice, ArraySlice, PlaneSlice, MipLevels, ArraySize()); }
}

pragma(inline, true) bool opEquals( const ref D3D12_RESOURCE_DESC l, const ref D3D12_RESOURCE_DESC r )
{
	return l.Dimension == r.Dimension &&
		l.Alignment == r.Alignment &&
		l.Width == r.Width &&
		l.Height == r.Height &&
		l.DepthOrArraySize == r.DepthOrArraySize &&
		l.MipLevels == r.MipLevels &&
		l.Format == r.Format &&
		l.SampleDesc.Count == r.SampleDesc.Count &&
		l.SampleDesc.Quality == r.SampleDesc.Quality &&
		l.Layout == r.Layout &&
		l.Flags == r.Flags;
}

//pragma(inline, true) bool operator!=( const ref D3D12_RESOURCE_DESC& l, const D3D12_RESOURCE_DESC r )
//{ return !( l == r ); }

//------------------------------------------------------------------------------------------------
struct CD3DX12_VIEW_INSTANCING_DESC
{
	D3D12_VIEW_INSTANCING_DESC m_D3D12_VIEW_INSTANCING_DESC;
	alias m_D3D12_VIEW_INSTANCING_DESC this;

	@safe nothrow:

	this(const ref D3D12_VIEW_INSTANCING_DESC o)
	{
		 m_D3D12_VIEW_INSTANCING_DESC = o;
	}
	
	this( CD3DX12_DEFAULT )
	{
		ViewInstanceCount = 0;
		pViewInstanceLocations = null;
		Flags = D3D12_VIEW_INSTANCING_FLAG_NONE;
	}
	
	this( 
		UINT InViewInstanceCount,
		const D3D12_VIEW_INSTANCE_LOCATION* InViewInstanceLocations,
		D3D12_VIEW_INSTANCING_FLAGS InFlags)
	{
		ViewInstanceCount = InViewInstanceCount;
		pViewInstanceLocations = InViewInstanceLocations;
		Flags = InFlags;
	}
}

//------------------------------------------------------------------------------------------------
// Row-by-row memcpy
pragma(inline, true) void MemcpySubresource(
	const D3D12_MEMCPY_DEST* pDest, // _In_
	const D3D12_SUBRESOURCE_DATA* pSrc, // _In_
	SIZE_T RowSizeInBytes,
	UINT NumRows,
	UINT NumSlices)
{
	for (UINT z = 0; z < NumSlices; ++z)
	{
		BYTE* pDestSlice = cast(BYTE*)(pDest.pData) + pDest.SlicePitch * z;
		const BYTE* pSrcSlice = cast(const BYTE*)(pSrc.pData) + pSrc.SlicePitch * z;
		for (UINT y = 0; y < NumRows; ++y)
		{
			memcpy(pDestSlice + pDest.RowPitch * y,
				   pSrcSlice + pSrc.RowPitch * y,
				   RowSizeInBytes);
		}
	}
}

//------------------------------------------------------------------------------------------------
// Returns required size of a buffer to be used for data upload
pragma(inline, true) UINT64 GetRequiredIntermediateSize(
	ID3D12Resource pDestinationResource, // _In_
	UINT FirstSubresource, // _In_range_(0,D3D12_REQ_SUBRESOURCES)
	UINT NumSubresources) // _In_range_(0,D3D12_REQ_SUBRESOURCES-FirstSubresource)
{
	D3D12_RESOURCE_DESC Desc = pDestinationResource.GetDesc();
	UINT64 RequiredSize = 0;
	
	ID3D12Device pDevice;
	pDestinationResource.GetDevice(&uuidof!(ID3D12Device), cast(void**)(&pDevice)); // TODO: this might be wrong usage of uuid
	pDevice.GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, 0, null, null, null, &RequiredSize);
	pDevice.Release();
	
	return RequiredSize;
}

//------------------------------------------------------------------------------------------------
// All arrays must be populated (e.g. by calling GetCopyableFootprints)
pragma(inline, true) UINT64 UpdateSubresources(
	ID3D12GraphicsCommandList pCmdList, // _In_ 
	ID3D12Resource pDestinationResource, // _In_ 
	ID3D12Resource pIntermediate, // _In_ 
	UINT FirstSubresource, // _In_range_(0,D3D12_REQ_SUBRESOURCES) 
	UINT NumSubresources, // _In_range_(0,D3D12_REQ_SUBRESOURCES-FirstSubresource) 
	UINT64 RequiredSize,
	const D3D12_PLACED_SUBRESOURCE_FOOTPRINT* pLayouts, // _In_reads_(NumSubresources) 
	const UINT* pNumRows, // _In_reads_(NumSubresources) 
	const UINT64* pRowSizesInBytes, // _In_reads_(NumSubresources) 
	const D3D12_SUBRESOURCE_DATA* pSrcData) // _In_reads_(NumSubresources) 
{
	// Minor validation
	const D3D12_RESOURCE_DESC IntermediateDesc = pIntermediate.GetDesc();
	const D3D12_RESOURCE_DESC DestinationDesc = pDestinationResource.GetDesc();
	if (IntermediateDesc.Dimension != D3D12_RESOURCE_DIMENSION_BUFFER || 
		IntermediateDesc.Width < RequiredSize + pLayouts[0].Offset || 
		RequiredSize > cast(SIZE_T)-1 || 
		(DestinationDesc.Dimension == D3D12_RESOURCE_DIMENSION_BUFFER && 
			(FirstSubresource != 0 || NumSubresources != 1)))
	{
		return 0;
	}
	
	BYTE* pData;
	HRESULT hr = pIntermediate.Map(0, null, cast(void**)(&pData));
	if (FAILED(hr))
	{
		return 0;
	}
	
	for (UINT i = 0; i < NumSubresources; ++i)
	{
		if (pRowSizesInBytes[i] > cast(SIZE_T)(-1)) return 0;
		D3D12_MEMCPY_DEST DestData = { pData + pLayouts[i].Offset, pLayouts[i].Footprint.RowPitch, pLayouts[i].Footprint.RowPitch * pNumRows[i] };
		MemcpySubresource(&DestData, &pSrcData[i], cast(SIZE_T)pRowSizesInBytes[i], pNumRows[i], pLayouts[i].Footprint.Depth);
	}
	pIntermediate.Unmap(0, null);
	
	if (DestinationDesc.Dimension == D3D12_RESOURCE_DIMENSION_BUFFER)
	{
		pCmdList.CopyBufferRegion(
			pDestinationResource, 0, pIntermediate, pLayouts[0].Offset, pLayouts[0].Footprint.Width);
	}
	else
	{
		for (UINT i = 0; i < NumSubresources; ++i)
		{
			CD3DX12_TEXTURE_COPY_LOCATION Dst = CD3DX12_TEXTURE_COPY_LOCATION(pDestinationResource, i + FirstSubresource);
			CD3DX12_TEXTURE_COPY_LOCATION Src = CD3DX12_TEXTURE_COPY_LOCATION(pIntermediate, pLayouts[i]);
			pCmdList.CopyTextureRegion(Dst.ptr(), 0, 0, 0, Src.ptr(), null);
		}
	}
	return RequiredSize;
}

//------------------------------------------------------------------------------------------------
// Heap-allocating UpdateSubresources implementation
pragma(inline, true) UINT64 UpdateSubresources( 
	ID3D12GraphicsCommandList pCmdList,	// _In_ 
	ID3D12Resource pDestinationResource,	// _In_ 
	ID3D12Resource pIntermediate,	// _In_ 
	UINT64 IntermediateOffset,
	UINT FirstSubresource,	// _In_range_(0,D3D12_REQ_SUBRESOURCES) 
	UINT NumSubresources, // _In_range_(0,D3D12_REQ_SUBRESOURCES-FirstSubresource) 
	D3D12_SUBRESOURCE_DATA* pSrcData) // _In_reads_(NumSubresources) 
{
	UINT64 RequiredSize = 0;
	UINT64 MemToAlloc = cast(UINT64)(D3D12_PLACED_SUBRESOURCE_FOOTPRINT.sizeof + UINT.sizeof + UINT64.sizeof) * NumSubresources;
	if (MemToAlloc > SIZE_MAX)
	{
	   return 0;
	}
	void* pMem = HeapAlloc(GetProcessHeap(), 0, cast(SIZE_T)(MemToAlloc));
	if (pMem == null)
	{
	   return 0;
	}
	D3D12_PLACED_SUBRESOURCE_FOOTPRINT* pLayouts = cast(D3D12_PLACED_SUBRESOURCE_FOOTPRINT*)(pMem);
	UINT64* pRowSizesInBytes = cast(UINT64*)(pLayouts + NumSubresources);
	UINT* pNumRows = cast(UINT*)(pRowSizesInBytes + NumSubresources);
	
	D3D12_RESOURCE_DESC Desc = pDestinationResource.GetDesc();
	ID3D12Device pDevice;
	pDestinationResource.GetDevice(&uuidof!(ID3D12Device), cast(void**)(&pDevice));
	pDevice.GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, IntermediateOffset, pLayouts, pNumRows, pRowSizesInBytes, &RequiredSize);
	pDevice.Release();
	
	UINT64 Result = UpdateSubresources(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, pLayouts, pNumRows, pRowSizesInBytes, pSrcData);
	HeapFree(GetProcessHeap(), 0, pMem);
	return Result;
}

//------------------------------------------------------------------------------------------------
// Stack-allocating UpdateSubresources implementation
//template <UINT MaxSubresources>
pragma(inline, true) UINT64 UpdateSubresources(UINT MaxSubresources)( 
	ID3D12GraphicsCommandList pCmdList,	// _In_ 
	ID3D12Resource pDestinationResource,	// _In_ 
	ID3D12Resource pIntermediate,	// _In_ 
	UINT64 IntermediateOffset,
	UINT FirstSubresource,	// _In_range_(0, MaxSubresources) 
	UINT NumSubresources, // _In_range_(1, MaxSubresources - FirstSubresource) 
	D3D12_SUBRESOURCE_DATA* pSrcData) // _In_reads_(NumSubresources) 
{
	UINT64 RequiredSize = 0;
	D3D12_PLACED_SUBRESOURCE_FOOTPRINT[MaxSubresources] Layouts;
	UINT[MaxSubresources] NumRows;
	UINT64[MaxSubresources] RowSizesInBytes;
	
	D3D12_RESOURCE_DESC Desc = pDestinationResource.GetDesc();
	ID3D12Device pDevice;
	pDestinationResource.GetDevice(&uuidof!(ID3D12Device), cast(void**)(&pDevice));
	pDevice.GetCopyableFootprints(&Desc, FirstSubresource, NumSubresources, IntermediateOffset, Layouts, NumRows, RowSizesInBytes, &RequiredSize);
	pDevice.Release();
	
	return UpdateSubresources(pCmdList, pDestinationResource, pIntermediate, FirstSubresource, NumSubresources, RequiredSize, Layouts, NumRows, RowSizesInBytes, pSrcData);
}

//------------------------------------------------------------------------------------------------
pragma(inline, true) bool D3D12IsLayoutOpaque( D3D12_TEXTURE_LAYOUT Layout )
{ return Layout == D3D12_TEXTURE_LAYOUT_UNKNOWN || Layout == D3D12_TEXTURE_LAYOUT_64KB_UNDEFINED_SWIZZLE; }

//------------------------------------------------------------------------------------------------
//template <typename t_CommandListType>
//pragma(inline, true) ID3D12CommandList * const * CommandListCast(t_CommandListType)(t_CommandListType * const * pp)
//{
//	// This cast is useful for passing strongly typed command list pointers into
//	// ExecuteCommandLists.
//	// This cast is valid as long as the const-ness is respected. D3D12 APIs do
//	// respect the const-ness of their arguments.
//	return cast(ID3D12CommandList * const *)(pp);
	// TODO: I need to see the syntax in action to get a sense of why this is useful.
	// Dlang has transitive const. There isn't a such thing a 'const pointer to mutable CommandList'.
//}

//------------------------------------------------------------------------------------------------
// D3D12 exports a new method for serializing root signatures in the Windows 10 Anniversary Update.
// To help enable root signature 1.1 features when they are available and not require maintaining
// two code paths for building root signatures, this helper method reconstructs a 1.0 signature when
// 1.1 is not supported.
pragma(inline, true) HRESULT D3DX12SerializeVersionedRootSignature(
	const D3D12_VERSIONED_ROOT_SIGNATURE_DESC* pRootSignatureDesc, // _In_ 
	D3D_ROOT_SIGNATURE_VERSION MaxVersion,
	ID3DBlob* ppBlob, // _Outptr_
	ID3DBlob* ppErrorBlob) // _Always_(_Outptr_opt_result_maybenull_) 
{
	if (ppErrorBlob != null)
	{
		*ppErrorBlob = null;
	}

	switch (MaxVersion)
	{
		case D3D_ROOT_SIGNATURE_VERSION_1_0:
			switch (pRootSignatureDesc.Version)
			{
				case D3D_ROOT_SIGNATURE_VERSION_1_0:
					return D3D12SerializeRootSignature(&pRootSignatureDesc.Desc_1_0, D3D_ROOT_SIGNATURE_VERSION_1, ppBlob, ppErrorBlob);

				case D3D_ROOT_SIGNATURE_VERSION_1_1:
				{
					HRESULT hr = S_OK;
					const (D3D12_ROOT_SIGNATURE_DESC1)* desc_1_1 = &pRootSignatureDesc.Desc_1_1;

					const SIZE_T ParametersSize = D3D12_ROOT_PARAMETER.sizeof * desc_1_1.NumParameters;
					void* pParameters = (ParametersSize > 0) ? HeapAlloc(GetProcessHeap(), 0, ParametersSize) : null;
					if (ParametersSize > 0 && pParameters == null)
					{
						hr = E_OUTOFMEMORY;
					}
					D3D12_ROOT_PARAMETER* pParameters_1_0 = cast(D3D12_ROOT_PARAMETER*)(pParameters);

					if (SUCCEEDED(hr))
					{
						for (UINT n = 0; n < desc_1_1.NumParameters; n++)
						{
							// __analysis_assume(ParametersSize == D3D12_ROOT_PARAMETER.sizeof * desc_1_1.NumParameters);
							pParameters_1_0[n].ParameterType = desc_1_1.pParameters[n].ParameterType;
							pParameters_1_0[n].ShaderVisibility = desc_1_1.pParameters[n].ShaderVisibility;

							switch (desc_1_1.pParameters[n].ParameterType)
							{
							case D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS:
								pParameters_1_0[n].Constants.Num32BitValues = desc_1_1.pParameters[n].Constants.Num32BitValues;
								pParameters_1_0[n].Constants.RegisterSpace = desc_1_1.pParameters[n].Constants.RegisterSpace;
								pParameters_1_0[n].Constants.ShaderRegister = desc_1_1.pParameters[n].Constants.ShaderRegister;
								break;

							case D3D12_ROOT_PARAMETER_TYPE_CBV:
							case D3D12_ROOT_PARAMETER_TYPE_SRV:
							case D3D12_ROOT_PARAMETER_TYPE_UAV:
								pParameters_1_0[n].Descriptor.RegisterSpace = desc_1_1.pParameters[n].Descriptor.RegisterSpace;
								pParameters_1_0[n].Descriptor.ShaderRegister = desc_1_1.pParameters[n].Descriptor.ShaderRegister;
								break;

							case D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE:
								const (D3D12_ROOT_DESCRIPTOR_TABLE1) *table_1_1 = &desc_1_1.pParameters[n].DescriptorTable;

								const SIZE_T DescriptorRangesSize = D3D12_DESCRIPTOR_RANGE.sizeof * table_1_1.NumDescriptorRanges;
								void* pDescriptorRanges = (DescriptorRangesSize > 0 && SUCCEEDED(hr)) ? HeapAlloc(GetProcessHeap(), 0, DescriptorRangesSize) : null;
								if (DescriptorRangesSize > 0 && pDescriptorRanges == null)
								{
									hr = E_OUTOFMEMORY;
								}
								D3D12_DESCRIPTOR_RANGE* pDescriptorRanges_1_0 = cast(D3D12_DESCRIPTOR_RANGE*)(pDescriptorRanges);

								if (SUCCEEDED(hr))
								{
									for (UINT x = 0; x < table_1_1.NumDescriptorRanges; x++)
									{
										//__analysis_assume(DescriptorRangesSize == D3D12_DESCRIPTOR_RANGE.sizeof * table_1_1.NumDescriptorRanges);
										pDescriptorRanges_1_0[x].BaseShaderRegister = table_1_1.pDescriptorRanges[x].BaseShaderRegister;
										pDescriptorRanges_1_0[x].NumDescriptors = table_1_1.pDescriptorRanges[x].NumDescriptors;
										pDescriptorRanges_1_0[x].OffsetInDescriptorsFromTableStart = table_1_1.pDescriptorRanges[x].OffsetInDescriptorsFromTableStart;
										pDescriptorRanges_1_0[x].RangeType = table_1_1.pDescriptorRanges[x].RangeType;
										pDescriptorRanges_1_0[x].RegisterSpace = table_1_1.pDescriptorRanges[x].RegisterSpace;
									}
								}

								pParameters_1_0[n].DescriptorTable.NumDescriptorRanges = table_1_1.NumDescriptorRanges;
								pParameters_1_0[n].DescriptorTable.pDescriptorRanges = pDescriptorRanges_1_0;
								break;
							default: break;
							}
						}
					}

					if (SUCCEEDED(hr))
					{
						CD3DX12_ROOT_SIGNATURE_DESC desc_1_0 = CD3DX12_ROOT_SIGNATURE_DESC(desc_1_1.NumParameters, pParameters_1_0, desc_1_1.NumStaticSamplers, desc_1_1.pStaticSamplers, desc_1_1.Flags);
						hr = D3D12SerializeRootSignature(desc_1_0.ptr(), D3D_ROOT_SIGNATURE_VERSION_1, ppBlob, ppErrorBlob);
					}

					if (pParameters)
					{
						for (UINT n = 0; n < desc_1_1.NumParameters; n++)
						{
							if (desc_1_1.pParameters[n].ParameterType == D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE)
							{
								HeapFree(GetProcessHeap(), 0, cast(void*)(cast(D3D12_DESCRIPTOR_RANGE*)(pParameters_1_0[n].DescriptorTable.pDescriptorRanges)));
							}
						}
						HeapFree(GetProcessHeap(), 0, pParameters);
					}
					return hr;
				}

				default: break;
			}
			break;

		case D3D_ROOT_SIGNATURE_VERSION_1_1:
			return D3D12SerializeVersionedRootSignature(pRootSignatureDesc, ppBlob, ppErrorBlob);
		default: break;
	}

	return E_INVALIDARG;
}

//------------------------------------------------------------------------------------------------

struct CD3DX12_RT_FORMAT_ARRAY
{
	D3D12_RT_FORMAT_ARRAY m_D3D12_RT_FORMAT_ARRAY;
	alias m_D3D12_RT_FORMAT_ARRAY this;

	this(const ref D3D12_RT_FORMAT_ARRAY o) @safe nothrow
	{
		m_D3D12_RT_FORMAT_ARRAY = o;
	}
	
	this(const DXGI_FORMAT* pFormats, UINT NumFormats) nothrow
	{
		NumRenderTargets = NumFormats;
		memcpy(RTFormats.ptr, pFormats, RTFormats.sizeof);
		// assumes ARRAY_SIZE(pFormats) == ARRAY_SIZE(RTFormats)
	}

	this(size_t length)(DXGI_FORMAT[length] Formats) nothrow
	{
		this(Formats.ptr, cast(uint) Formats.length);
		static assert(Formats.sizeof == RTFormats.sizeof);
	}
}

//------------------------------------------------------------------------------------------------
// Pipeline State Stream Helpers
//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------
// Stream Subobjects, i.e. elements of a stream

struct DefaultSampleMask 
{
	immutable UINT value = UINT_MAX;
	alias value this;
}

struct DefaultSampleDesc 
{
	immutable DXGI_SAMPLE_DESC value = {1, 0};
	alias value this;
}

align((void*).sizeof) 
struct CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT(InnerStructType, D3D12_PIPELINE_STATE_SUBOBJECT_TYPE Type, DefaultArg = InnerStructType)
{
private:
	D3D12_PIPELINE_STATE_SUBOBJECT_TYPE _Type = Type;

	// Notes on this exception for interfaces:
	// 	TL:DR:
	// 		So if the inner type is some primivite, like int, everything works via copying and it's just fine.
	//		
	// 		However, when the inner type is a reference type, like a class or interface, the constructor takes in
	// 		a 'const(InnerStructType)'. If _Inner was declared as InnerStructType, this is not assignable:
	// 		'cannot implicitly convert expression i of type const(InterfaceType) to InterfaceType'
	//
	// 	Workaround: 
	// 		For interface types of InnerStructType, declare _Inner as 'const(InnerStructType) _Inner'.
	// 		Taking in a const reference type in the constructor assigns properly.
	//		
	// 		For value types of InnerStructType, declare _Inner as 'InnerStructType _Inner'.
	// 		This is like saying 
	// 		"mutable, copyable top-level value type (pointer or primitive), and const any types below the top level".
	//

	import std.typecons : Rebindable;
	// Gotta use Rebindable to make a mutable reference to a const object. Otherwise, assignment to a new 
	// ID3D12RootSignature results in 
	// 'cannot modify struct this.PipelineStream.pRootSignature CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!(ID3D12RootSignature, 0u, ID3D12RootSignature) with immutable members'

	static if(is(InnerStructType == interface))
	{
		Rebindable!(const InnerStructType) _Inner = null;
	}
	else
	{
		InnerStructType _Inner = DefaultArg();
	}
	
public:
	
	this(T)(const auto ref T i)
	{
		_Inner = i;
	}

	@property InnerStructType get() const
	{
		return cast(InnerStructType)(_Inner);
	}

	alias _Inner this;
}

alias CD3DX12_PIPELINE_STATE_STREAM_FLAGS = 				CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_PIPELINE_STATE_FLAGS,		 D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_FLAGS);
alias CD3DX12_PIPELINE_STATE_STREAM_NODE_MASK = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( UINT,							   D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_NODE_MASK);
alias CD3DX12_PIPELINE_STATE_STREAM_ROOT_SIGNATURE = 		CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( ID3D12RootSignature,				D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_ROOT_SIGNATURE);
alias CD3DX12_PIPELINE_STATE_STREAM_INPUT_LAYOUT = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_INPUT_LAYOUT_DESC,			D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_INPUT_LAYOUT);
alias CD3DX12_PIPELINE_STATE_STREAM_IB_STRIP_CUT_VALUE = 	CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_INDEX_BUFFER_STRIP_CUT_VALUE, D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_IB_STRIP_CUT_VALUE);
alias CD3DX12_PIPELINE_STATE_STREAM_PRIMITIVE_TOPOLOGY = 	CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_PRIMITIVE_TOPOLOGY_TYPE,	  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_PRIMITIVE_TOPOLOGY);
alias CD3DX12_PIPELINE_STATE_STREAM_VS = 					CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_SHADER_BYTECODE,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_VS);
alias CD3DX12_PIPELINE_STATE_STREAM_GS = 					CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_SHADER_BYTECODE,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_GS);
alias CD3DX12_PIPELINE_STATE_STREAM_STREAM_OUTPUT = 		CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_STREAM_OUTPUT_DESC,		   D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_STREAM_OUTPUT);
alias CD3DX12_PIPELINE_STATE_STREAM_HS = 					CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_SHADER_BYTECODE,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_HS);
alias CD3DX12_PIPELINE_STATE_STREAM_DS = 					CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_SHADER_BYTECODE,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DS);
alias CD3DX12_PIPELINE_STATE_STREAM_PS = 					CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_SHADER_BYTECODE,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_PS);
alias CD3DX12_PIPELINE_STATE_STREAM_CS = 					CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_SHADER_BYTECODE,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_CS);
alias CD3DX12_PIPELINE_STATE_STREAM_BLEND_DESC = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( CD3DX12_BLEND_DESC,				 D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_BLEND,		  CD3DX12_DEFAULT);
alias CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL = 		CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( CD3DX12_DEPTH_STENCIL_DESC,		 D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL,  CD3DX12_DEFAULT);
alias CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL1 = 		CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( CD3DX12_DEPTH_STENCIL_DESC1,		D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL1, CD3DX12_DEFAULT);
alias CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL_FORMAT = 	CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( DXGI_FORMAT,						D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL_FORMAT);
alias CD3DX12_PIPELINE_STATE_STREAM_RASTERIZER = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( CD3DX12_RASTERIZER_DESC,			D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_RASTERIZER,	 CD3DX12_DEFAULT);
alias CD3DX12_PIPELINE_STATE_STREAM_RENDER_TARGET_FORMATS = CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_RT_FORMAT_ARRAY,			  D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_RENDER_TARGET_FORMATS);
alias CD3DX12_PIPELINE_STATE_STREAM_SAMPLE_DESC = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( DXGI_SAMPLE_DESC,				   D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_SAMPLE_DESC,	DefaultSampleDesc);
alias CD3DX12_PIPELINE_STATE_STREAM_SAMPLE_MASK = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( UINT,							   D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_SAMPLE_MASK,	DefaultSampleMask);
alias CD3DX12_PIPELINE_STATE_STREAM_CACHED_PSO = 			CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( D3D12_CACHED_PIPELINE_STATE,		D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_CACHED_PSO);
alias CD3DX12_PIPELINE_STATE_STREAM_VIEW_INSTANCING = 		CD3DX12_PIPELINE_STATE_STREAM_SUBOBJECT!( CD3DX12_VIEW_INSTANCING_DESC,	   D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_VIEW_INSTANCING, CD3DX12_DEFAULT); 

//------------------------------------------------------------------------------------------------
// Stream Parser Helpers 

class ID3DX12PipelineParserCallbacks
{
	// Subobject Callbacks
	void FlagsCb(D3D12_PIPELINE_STATE_FLAGS) {}
	void NodeMaskCb(UINT) {}
	void RootSignatureCb(ID3D12RootSignature) {}
	void InputLayoutCb(const ref D3D12_INPUT_LAYOUT_DESC) {}
	void IBStripCutValueCb(D3D12_INDEX_BUFFER_STRIP_CUT_VALUE) {}
	void PrimitiveTopologyTypeCb(D3D12_PRIMITIVE_TOPOLOGY_TYPE) {}
	void VSCb(const ref D3D12_SHADER_BYTECODE) {}
	void GSCb(const ref D3D12_SHADER_BYTECODE) {}
	void StreamOutputCb(const ref D3D12_STREAM_OUTPUT_DESC) {}
	void HSCb(const ref D3D12_SHADER_BYTECODE) {}
	void DSCb(const ref D3D12_SHADER_BYTECODE) {}
	void PSCb(const ref D3D12_SHADER_BYTECODE) {}
	void CSCb(const ref D3D12_SHADER_BYTECODE) {}
	void BlendStateCb(const ref D3D12_BLEND_DESC) {}
	void DepthStencilStateCb(const ref D3D12_DEPTH_STENCIL_DESC) {}
	void DepthStencilState1Cb(const ref D3D12_DEPTH_STENCIL_DESC1) {}
	void DSVFormatCb(DXGI_FORMAT) {}
	void RasterizerStateCb(const ref D3D12_RASTERIZER_DESC) {}
	void RTVFormatsCb(const ref D3D12_RT_FORMAT_ARRAY) {}
	void SampleDescCb(const ref DXGI_SAMPLE_DESC) {}
	void SampleMaskCb(UINT) {}
	void ViewInstancingCb(const ref D3D12_VIEW_INSTANCING_DESC) {}
	void CachedPSOCb(const ref D3D12_CACHED_PIPELINE_STATE) {}

	// Error Callbacks
	void ErrorBadInputParameter(UINT /*ParameterIndex*/) {}
	void ErrorDuplicateSubobject(D3D12_PIPELINE_STATE_SUBOBJECT_TYPE /*DuplicateType*/) {}
	void ErrorUnknownSubobject(UINT /*UnknownTypeValue*/) {}
}

// CD3DX12_PIPELINE_STATE_STREAM1 Works on RS3+ (where there is a new view instancing subobject).  
// Use CD3DX12_PIPELINE_STATE_STREAM for RS2+ support.
struct CD3DX12_PIPELINE_STATE_STREAM1
{
	this(ref const(D3D12_GRAPHICS_PIPELINE_STATE_DESC) Desc) 
	{
		Flags = Desc.Flags;
		NodeMask = Desc.NodeMask;
		pRootSignature = Desc.pRootSignature;
		InputLayout = Desc.InputLayout;
		IBStripCutValue = Desc.IBStripCutValue;
		PrimitiveTopologyType = Desc.PrimitiveTopologyType;
		VS = Desc.VS;
		GS = Desc.GS;
		StreamOutput = Desc.StreamOutput;
		HS = Desc.HS;
		DS = Desc.DS;
		PS = Desc.PS;
		BlendState = CD3DX12_BLEND_DESC(Desc.BlendState);
		DepthStencilState = CD3DX12_DEPTH_STENCIL_DESC1(Desc.DepthStencilState);
		DSVFormat = Desc.DSVFormat;
		RasterizerState = CD3DX12_RASTERIZER_DESC(Desc.RasterizerState);
		RTVFormats = CD3DX12_RT_FORMAT_ARRAY(Desc.RTVFormats.ptr, Desc.NumRenderTargets);
		SampleDesc = Desc.SampleDesc;
		SampleMask = Desc.SampleMask;
		CachedPSO = Desc.CachedPSO;
		ViewInstancingDesc = CD3DX12_VIEW_INSTANCING_DESC(CD3DX12_DEFAULT());
	}

	this(const ref D3D12_COMPUTE_PIPELINE_STATE_DESC Desc)
	{
		Flags = Desc.Flags;
		NodeMask = Desc.NodeMask;
		pRootSignature = Desc.pRootSignature;
		CS = CD3DX12_SHADER_BYTECODE(Desc.CS);
		CachedPSO = Desc.CachedPSO;
		DepthStencilState.DepthEnable = false;
	}

	CD3DX12_PIPELINE_STATE_STREAM_FLAGS Flags;
	CD3DX12_PIPELINE_STATE_STREAM_NODE_MASK NodeMask;
	CD3DX12_PIPELINE_STATE_STREAM_ROOT_SIGNATURE pRootSignature;
	CD3DX12_PIPELINE_STATE_STREAM_INPUT_LAYOUT InputLayout;
	CD3DX12_PIPELINE_STATE_STREAM_IB_STRIP_CUT_VALUE IBStripCutValue;
	CD3DX12_PIPELINE_STATE_STREAM_PRIMITIVE_TOPOLOGY PrimitiveTopologyType;
	CD3DX12_PIPELINE_STATE_STREAM_VS VS;
	CD3DX12_PIPELINE_STATE_STREAM_GS GS;
	CD3DX12_PIPELINE_STATE_STREAM_STREAM_OUTPUT StreamOutput;
	CD3DX12_PIPELINE_STATE_STREAM_HS HS;
	CD3DX12_PIPELINE_STATE_STREAM_DS DS;
	CD3DX12_PIPELINE_STATE_STREAM_PS PS;
	CD3DX12_PIPELINE_STATE_STREAM_CS CS;
	CD3DX12_PIPELINE_STATE_STREAM_BLEND_DESC BlendState;
	CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL1 DepthStencilState;
	CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL_FORMAT DSVFormat;
	CD3DX12_PIPELINE_STATE_STREAM_RASTERIZER RasterizerState;
	CD3DX12_PIPELINE_STATE_STREAM_RENDER_TARGET_FORMATS RTVFormats;
	CD3DX12_PIPELINE_STATE_STREAM_SAMPLE_DESC SampleDesc;
	CD3DX12_PIPELINE_STATE_STREAM_SAMPLE_MASK SampleMask;
	CD3DX12_PIPELINE_STATE_STREAM_CACHED_PSO CachedPSO;
	CD3DX12_PIPELINE_STATE_STREAM_VIEW_INSTANCING ViewInstancingDesc;

	D3D12_GRAPHICS_PIPELINE_STATE_DESC GraphicsDescV0() const
	{
		D3D12_GRAPHICS_PIPELINE_STATE_DESC D;
		D.Flags				 = this.Flags;
		D.NodeMask			  = this.NodeMask;
		D.pRootSignature		= cast(ID3D12RootSignature)(this.pRootSignature);
		D.InputLayout		   = this.InputLayout;
		D.IBStripCutValue	   = this.IBStripCutValue;
		D.PrimitiveTopologyType = this.PrimitiveTopologyType;
		D.VS					= this.VS;
		D.GS					= this.GS;
		D.StreamOutput		  = this.StreamOutput;
		D.HS					= this.HS;
		D.DS					= this.DS;
		D.PS					= this.PS;
		D.BlendState			= this.BlendState;
		D.DepthStencilState	 = cast(D3D12_DEPTH_STENCIL_DESC)(this.DepthStencilState);
		D.DSVFormat			 = this.DSVFormat;
		D.RasterizerState	   = this.RasterizerState;
		D.NumRenderTargets	  = this.RTVFormats.NumRenderTargets;
		D.RTVFormats			= this.RTVFormats.RTFormats;
		D.SampleDesc			= this.SampleDesc;
		D.SampleMask			= this.SampleMask;
		D.CachedPSO			 = this.CachedPSO;
		return D;
	}

	D3D12_COMPUTE_PIPELINE_STATE_DESC ComputeDescV0() const
	{
		D3D12_COMPUTE_PIPELINE_STATE_DESC D;
		D.Flags				 = this.Flags;
		D.NodeMask			  = this.NodeMask;
		D.pRootSignature		= cast(ID3D12RootSignature)(this.pRootSignature);
		D.CS					= this.CS;
		D.CachedPSO			 = this.CachedPSO;
		return D;
	}
}

// CD3DX12_PIPELINE_STATE_STREAM works on RS2+ but does not support new subobject(s) added in RS3+.
// See CD3DX12_PIPELINE_STATE_STREAM1 for instance.
struct CD3DX12_PIPELINE_STATE_STREAM
{
	this(const ref D3D12_GRAPHICS_PIPELINE_STATE_DESC Desc)
	{
		Flags = Desc.Flags;
		NodeMask = Desc.NodeMask;
		pRootSignature = Desc.pRootSignature;
		InputLayout = Desc.InputLayout;
		IBStripCutValue = Desc.IBStripCutValue;
		PrimitiveTopologyType = Desc.PrimitiveTopologyType;
		VS = Desc.VS;
		GS = Desc.GS;
		StreamOutput = Desc.StreamOutput;
		HS = Desc.HS;
		DS = Desc.DS;
		PS = Desc.PS;
		BlendState = CD3DX12_BLEND_DESC(Desc.BlendState);
		DepthStencilState = CD3DX12_DEPTH_STENCIL_DESC1(Desc.DepthStencilState);
		DSVFormat = Desc.DSVFormat;
		RasterizerState = CD3DX12_RASTERIZER_DESC(Desc.RasterizerState);
		RTVFormats = CD3DX12_RT_FORMAT_ARRAY(Desc.RTVFormats.ptr, Desc.NumRenderTargets);
		SampleDesc = Desc.SampleDesc;
		SampleMask = Desc.SampleMask;
		CachedPSO = Desc.CachedPSO;
	}

	this(const ref D3D12_COMPUTE_PIPELINE_STATE_DESC Desc)
	{
		Flags = Desc.Flags;
		NodeMask = Desc.NodeMask;
		pRootSignature = Desc.pRootSignature;
		CS = CD3DX12_SHADER_BYTECODE(Desc.CS);
		CachedPSO = Desc.CachedPSO;

	}
	CD3DX12_PIPELINE_STATE_STREAM_FLAGS Flags;
	CD3DX12_PIPELINE_STATE_STREAM_NODE_MASK NodeMask;
	CD3DX12_PIPELINE_STATE_STREAM_ROOT_SIGNATURE pRootSignature;
	CD3DX12_PIPELINE_STATE_STREAM_INPUT_LAYOUT InputLayout;
	CD3DX12_PIPELINE_STATE_STREAM_IB_STRIP_CUT_VALUE IBStripCutValue;
	CD3DX12_PIPELINE_STATE_STREAM_PRIMITIVE_TOPOLOGY PrimitiveTopologyType;
	CD3DX12_PIPELINE_STATE_STREAM_VS VS;
	CD3DX12_PIPELINE_STATE_STREAM_GS GS;
	CD3DX12_PIPELINE_STATE_STREAM_STREAM_OUTPUT StreamOutput;
	CD3DX12_PIPELINE_STATE_STREAM_HS HS;
	CD3DX12_PIPELINE_STATE_STREAM_DS DS;
	CD3DX12_PIPELINE_STATE_STREAM_PS PS;
	CD3DX12_PIPELINE_STATE_STREAM_CS CS;
	CD3DX12_PIPELINE_STATE_STREAM_BLEND_DESC BlendState;
	CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL1 DepthStencilState;
	CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL_FORMAT DSVFormat;
	CD3DX12_PIPELINE_STATE_STREAM_RASTERIZER RasterizerState;
	CD3DX12_PIPELINE_STATE_STREAM_RENDER_TARGET_FORMATS RTVFormats;
	CD3DX12_PIPELINE_STATE_STREAM_SAMPLE_DESC SampleDesc;
	CD3DX12_PIPELINE_STATE_STREAM_SAMPLE_MASK SampleMask;
	CD3DX12_PIPELINE_STATE_STREAM_CACHED_PSO CachedPSO;

	D3D12_GRAPHICS_PIPELINE_STATE_DESC GraphicsDescV0() const
	{
		D3D12_GRAPHICS_PIPELINE_STATE_DESC D;
		D.Flags				 = this.Flags;
		D.NodeMask			  = this.NodeMask;
		D.pRootSignature		= cast(ID3D12RootSignature)(this.pRootSignature);
		D.InputLayout		   = this.InputLayout;
		D.IBStripCutValue	   = this.IBStripCutValue;
		D.PrimitiveTopologyType = this.PrimitiveTopologyType;
		D.VS					= this.VS;
		D.GS					= this.GS;
		D.StreamOutput		  = this.StreamOutput;
		D.HS					= this.HS;
		D.DS					= this.DS;
		D.PS					= this.PS;
		D.BlendState			= this.BlendState;
		D.DepthStencilState	 = cast(D3D12_DEPTH_STENCIL_DESC)(this.DepthStencilState);
		D.DSVFormat			 = this.DSVFormat;
		D.RasterizerState	   = this.RasterizerState;
		D.NumRenderTargets	  = this.RTVFormats.NumRenderTargets;
		D.RTVFormats			= this.RTVFormats.RTFormats;
		D.SampleDesc			= this.SampleDesc;
		D.SampleMask			= this.SampleMask;
		D.CachedPSO			 = this.CachedPSO;
		return D;
	}

	D3D12_COMPUTE_PIPELINE_STATE_DESC ComputeDescV0() const
	{
		D3D12_COMPUTE_PIPELINE_STATE_DESC D;
		D.Flags				 = this.Flags;
		D.NodeMask			  = this.NodeMask;
		D.pRootSignature		= cast(ID3D12RootSignature)(this.pRootSignature);
		D.CS					= this.CS;
		D.CachedPSO			 = this.CachedPSO;
		return D;
	}
}

class CD3DX12_PIPELINE_STATE_STREAM_PARSE_HELPER : ID3DX12PipelineParserCallbacks
{
	CD3DX12_PIPELINE_STATE_STREAM1 PipelineStream;

	this()
	{
		// Adjust defaults to account for absent members.
		PipelineStream.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;

		// Depth disabled if no DSV format specified.
		PipelineStream.DepthStencilState.DepthEnable = false;
	}
	
	~this() { }

	// ID3DX12PipelineParserCallbacks
	override
	{
		void FlagsCb(D3D12_PIPELINE_STATE_FLAGS Flags) {PipelineStream.Flags = Flags;}
		void NodeMaskCb(UINT NodeMask) {PipelineStream.NodeMask = NodeMask;}
		//void RootSignatureCb(ID3D12RootSignature pRootSignature) { PipelineStream.pRootSignature = pRootSignature; } // TODO
		void InputLayoutCb(const ref D3D12_INPUT_LAYOUT_DESC InputLayout) {PipelineStream.InputLayout = InputLayout;}
		void IBStripCutValueCb(D3D12_INDEX_BUFFER_STRIP_CUT_VALUE IBStripCutValue) {PipelineStream.IBStripCutValue = IBStripCutValue;}
		void PrimitiveTopologyTypeCb(D3D12_PRIMITIVE_TOPOLOGY_TYPE PrimitiveTopologyType) {PipelineStream.PrimitiveTopologyType = PrimitiveTopologyType;}
		void VSCb(const ref D3D12_SHADER_BYTECODE VS) {PipelineStream.VS = VS;}
		void GSCb(const ref D3D12_SHADER_BYTECODE GS) {PipelineStream.GS = GS;}
		void StreamOutputCb(const ref D3D12_STREAM_OUTPUT_DESC StreamOutput) {PipelineStream.StreamOutput = StreamOutput;}
		void HSCb(const ref D3D12_SHADER_BYTECODE HS) {PipelineStream.HS = HS;}
		void DSCb(const ref D3D12_SHADER_BYTECODE DS) {PipelineStream.DS = DS;}
		void PSCb(const ref D3D12_SHADER_BYTECODE PS) {PipelineStream.PS = PS;}
		void CSCb(const ref D3D12_SHADER_BYTECODE CS) {PipelineStream.CS = CS;}
		void BlendStateCb(const ref D3D12_BLEND_DESC BlendState) {PipelineStream.BlendState = CD3DX12_BLEND_DESC(BlendState);}
		void DepthStencilStateCb(const ref D3D12_DEPTH_STENCIL_DESC DepthStencilState)
		{
			PipelineStream.DepthStencilState = CD3DX12_DEPTH_STENCIL_DESC1(DepthStencilState);
			SeenDSS = true;
		}
		void DepthStencilState1Cb(const ref D3D12_DEPTH_STENCIL_DESC1 DepthStencilState)
		{
			PipelineStream.DepthStencilState = CD3DX12_DEPTH_STENCIL_DESC1(DepthStencilState);
			SeenDSS = true;
		}
		void DSVFormatCb(DXGI_FORMAT DSVFormat)
		{
			PipelineStream.DSVFormat = DSVFormat;
			if (!SeenDSS && DSVFormat != DXGI_FORMAT_UNKNOWN)
			{
				// Re-enable depth for the default state.
				PipelineStream.DepthStencilState.DepthEnable = true;
			}
		}
		void RasterizerStateCb(const ref D3D12_RASTERIZER_DESC RasterizerState) {PipelineStream.RasterizerState = CD3DX12_RASTERIZER_DESC(RasterizerState);}
		void RTVFormatsCb(const ref D3D12_RT_FORMAT_ARRAY RTVFormats) {PipelineStream.RTVFormats = RTVFormats;}
		void SampleDescCb(const ref DXGI_SAMPLE_DESC SampleDesc) {PipelineStream.SampleDesc = SampleDesc;}
		void SampleMaskCb(UINT SampleMask) {PipelineStream.SampleMask = SampleMask;}
		void ViewInstancingCb(const ref D3D12_VIEW_INSTANCING_DESC ViewInstancingDesc) {PipelineStream.ViewInstancingDesc = CD3DX12_VIEW_INSTANCING_DESC(ViewInstancingDesc);}
		void CachedPSOCb(const ref D3D12_CACHED_PIPELINE_STATE CachedPSO) {PipelineStream.CachedPSO = CachedPSO;}
		void ErrorBadInputParameter(UINT) {}
		void ErrorDuplicateSubobject(D3D12_PIPELINE_STATE_SUBOBJECT_TYPE) {}
		void ErrorUnknownSubobject(UINT) {}
	}

private:
	bool SeenDSS = false;
}
 
pragma(inline, true) D3D12_PIPELINE_STATE_SUBOBJECT_TYPE D3DX12GetBaseSubobjectType(D3D12_PIPELINE_STATE_SUBOBJECT_TYPE SubobjectType)
{
	switch (SubobjectType)
	{
	case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL1: 
		return D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL;
	default:
		return SubobjectType;
	}
}

pragma(inline, true) HRESULT D3DX12ParsePipelineStream(const ref D3D12_PIPELINE_STATE_STREAM_DESC Desc, ID3DX12PipelineParserCallbacks* pCallbacks)
{
	if (pCallbacks == null)
	{
		return E_INVALIDARG;
	}

	if (Desc.SizeInBytes == 0 || Desc.pPipelineStateSubobjectStream == null)
	{
		pCallbacks.ErrorBadInputParameter(1); // first parameter issue
		return E_INVALIDARG;
	}

	bool[D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_MAX_VALID] SubobjectSeen = false;
	for (SIZE_T CurOffset = 0, SizeOfSubobject = 0; CurOffset < Desc.SizeInBytes; CurOffset += SizeOfSubobject)
	{
		BYTE* pStream = (cast(BYTE*)(Desc.pPipelineStateSubobjectStream)) + CurOffset;
		auto SubobjectType = *cast(D3D12_PIPELINE_STATE_SUBOBJECT_TYPE*)(pStream);
		if (SubobjectType >= D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_MAX_VALID)
		{
			pCallbacks.ErrorUnknownSubobject(SubobjectType);
			return E_INVALIDARG;
		}
		if (SubobjectSeen[D3DX12GetBaseSubobjectType(SubobjectType)])
		{
			pCallbacks.ErrorDuplicateSubobject(SubobjectType);
			return E_INVALIDARG; // disallow subobject duplicates in a stream
		}
		SubobjectSeen[SubobjectType] = true;
		switch (SubobjectType)
		{
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_ROOT_SIGNATURE: 
			auto temp = cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.pRootSignature)*)(pStream);
			pCallbacks.RootSignatureCb(temp.get);
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.pRootSignature.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_VS:
			pCallbacks.VSCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.VS)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.VS.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_PS: 
			pCallbacks.PSCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.PS)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.PS.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DS: 
			pCallbacks.DSCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.DS)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.DS.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_HS: 
			pCallbacks.HSCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.HS)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.HS.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_GS: 
			pCallbacks.GSCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.GS)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.GS.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_CS:
			pCallbacks.CSCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.CS)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.CS.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_STREAM_OUTPUT: 
			pCallbacks.StreamOutputCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.StreamOutput)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.StreamOutput.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_BLEND: 
			pCallbacks.BlendStateCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.BlendState)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.BlendState.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_SAMPLE_MASK: 
			pCallbacks.SampleMaskCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.SampleMask)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.SampleMask.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_RASTERIZER: 
			pCallbacks.RasterizerStateCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.RasterizerState)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.RasterizerState.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL: 
			pCallbacks.DepthStencilStateCb(*cast(CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM_DEPTH_STENCIL.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL1: 
			pCallbacks.DepthStencilState1Cb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.DepthStencilState)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.DepthStencilState.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_INPUT_LAYOUT: 
			pCallbacks.InputLayoutCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.InputLayout)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.InputLayout.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_IB_STRIP_CUT_VALUE: 
			pCallbacks.IBStripCutValueCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.IBStripCutValue)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.IBStripCutValue.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_PRIMITIVE_TOPOLOGY: 
			pCallbacks.PrimitiveTopologyTypeCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.PrimitiveTopologyType)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.PrimitiveTopologyType.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_RENDER_TARGET_FORMATS: 
			pCallbacks.RTVFormatsCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.RTVFormats)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.RTVFormats.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_DEPTH_STENCIL_FORMAT: 
			pCallbacks.DSVFormatCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.DSVFormat)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.DSVFormat.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_SAMPLE_DESC: 
			pCallbacks.SampleDescCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.SampleDesc)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.SampleDesc.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_NODE_MASK: 
			pCallbacks.NodeMaskCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.NodeMask)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.NodeMask.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_CACHED_PSO: 
			pCallbacks.CachedPSOCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.CachedPSO)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.CachedPSO.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_FLAGS:
			pCallbacks.FlagsCb(*cast(typeof(CD3DX12_PIPELINE_STATE_STREAM.Flags)*)(pStream));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM.Flags.sizeof;
			break;
		case D3D12_PIPELINE_STATE_SUBOBJECT_TYPE_VIEW_INSTANCING:
			pCallbacks.ViewInstancingCb(*(cast(typeof(CD3DX12_PIPELINE_STATE_STREAM1.ViewInstancingDesc)*)(pStream)));
			SizeOfSubobject = CD3DX12_PIPELINE_STATE_STREAM1.ViewInstancingDesc.sizeof;
			break;
		default:
			pCallbacks.ErrorUnknownSubobject(SubobjectType);
			return E_INVALIDARG;
		}
	}

	return S_OK;
}

