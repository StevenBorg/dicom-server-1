﻿// -------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License (MIT). See LICENSE in the repo root for license information.
// -------------------------------------------------------------------------------------------------
using Dicom;

namespace Microsoft.Health.Dicom.Core.Features.Query
{
    public abstract class DicomQueryFilterCondition
    {
        public DicomQueryFilterCondition(DicomTag tag)
        {
            DicomTag = tag;
        }

        public DicomTag DicomTag { get; }
    }

    public class DicomQuerySingleValueFilterCondition<T> : DicomQueryFilterCondition
    {
        internal DicomQuerySingleValueFilterCondition(DicomTag tag, T value)
            : base(tag)
        {
            Value = value;
        }

        public T Value { get; }
    }

    public class DicomQueryRangeValueFilterCondition<T> : DicomQueryFilterCondition
    {
        internal DicomQueryRangeValueFilterCondition(DicomTag tag, T minimum, T maximum)
            : base(tag)
        {
            Minimum = minimum;
            Maximum = maximum;
        }

        public T Minimum { get; set; }

        public T Maximum { get; set; }
    }
}
